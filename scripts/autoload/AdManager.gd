extends Node

## AdManager - Handles AdMob integration for rewarded ads (Godot 4.x Poing Studios Plugin)

signal ad_loaded
signal ad_failed_to_load
signal ad_displayed
signal ad_closed
signal reward_earned

# Toggle between test and production ads
# Set to false for production release!
const USE_TEST_ADS: bool = false

# Production IDs
const PROD_ANDROID_REWARDED_AD_ID = "ca-app-pub-2547513308278750/3568656364"
const PROD_IOS_REWARDED_AD_ID = ""  # TODO: Add iOS Rewarded Ad ID when available

# Test IDs (for development)
const TEST_ANDROID_REWARDED_AD_ID = "ca-app-pub-3940256099942544/5224354917"
const TEST_IOS_REWARDED_AD_ID = "ca-app-pub-3940256099942544/1712485313"

# Poing Studios AdMob plugin objects
var rewarded_ad: RewardedAd = null
var on_user_earned_reward_listener := OnUserEarnedRewardListener.new()

var is_ad_loaded: bool = false
var is_plugin_available: bool = false
var is_loading: bool = false

# Retry timer system
var retry_timer: Timer

const AD_RETRY_DELAY: float = 5.0

func _ready() -> void:
	print("========================================")
	print("AdManager _ready() called")
	print("========================================")

	# Check if AdMob plugin is available
	check_plugin_availability()

	# Setup reward listener
	on_user_earned_reward_listener.on_user_earned_reward = _on_user_earned_reward

	# Setup retry timer
	retry_timer = Timer.new()
	retry_timer.one_shot = true
	retry_timer.wait_time = AD_RETRY_DELAY
	retry_timer.timeout.connect(_on_retry_timeout)
	add_child(retry_timer)

	# Initialize AdMob if available (deferred to avoid blocking startup)
	if is_plugin_available:
		# Use call_deferred to ensure scene tree is fully ready
		call_deferred("_initialize_admob_deferred")
	else:
		print("AdMob plugin not available - using fallback mode only")

func _initialize_admob_deferred() -> void:
	# Defer initialization significantly to ensure app starts smoothly
	# Large delays for AAB builds to avoid startup hangs
	await get_tree().create_timer(5.0).timeout
	initialize_admob()
	# Defer ad loading to avoid blocking if network is slow
	await get_tree().create_timer(3.0).timeout
	load_rewarded_ad()

func check_plugin_availability() -> void:
	# Check if the native plugin singleton is available
	# The Poing Studios plugin registers a singleton called "PoingGodotAdMobRewardedAd"
	print("========================================")
	print("Platform: ", OS.get_name())
	print("Checking for PoingGodotAdMobRewardedAd singleton...")
	is_plugin_available = Engine.has_singleton("PoingGodotAdMobRewardedAd")
	print("Engine.has_singleton('PoingGodotAdMobRewardedAd') = ", is_plugin_available)
	print("========================================")

	if is_plugin_available:
		print("✅ AdMob plugin detected (Poing Studios Godot 4.x)")
	else:
		print("❌ AdMob plugin not detected - using fallback mode")

func initialize_admob() -> void:
	if not is_plugin_available:
		return

	print("🎬 Initializing AdMob...")
	var mode = "TEST" if USE_TEST_ADS else "PRODUCTION"
	print("AdMob Mode: ", mode)

	# Initialize MobileAds SDK (required - should be done once at app launch)
	var on_initialization_complete_listener := OnInitializationCompleteListener.new()
	on_initialization_complete_listener.on_initialization_complete = _on_admob_initialized
	MobileAds.initialize(on_initialization_complete_listener)

func _on_admob_initialized(initialization_status: InitializationStatus) -> void:
	print("✅ AdMob SDK initialized successfully")

func load_rewarded_ad() -> void:
	if not is_plugin_available:
		print("Cannot load ad - AdMob plugin not available")
		return

	if is_loading:
		print("Ad already loading...")
		return

	if is_ad_loaded:
		print("Ad already loaded")
		return

	is_loading = true

	# Free memory from previous ad
	if rewarded_ad:
		rewarded_ad.destroy()
		rewarded_ad = null

	# Get appropriate ad unit ID based on platform and test mode
	var ad_unit_id: String
	if OS.get_name() == "Android":
		ad_unit_id = TEST_ANDROID_REWARDED_AD_ID if USE_TEST_ADS else PROD_ANDROID_REWARDED_AD_ID
	else:
		ad_unit_id = TEST_IOS_REWARDED_AD_ID if USE_TEST_ADS else PROD_IOS_REWARDED_AD_ID

	# Load rewarded ad using Poing Studios API
	print("📥 Loading rewarded ad (", "TEST" if USE_TEST_ADS else "PRODUCTION", ")...")
	print("Ad Unit ID: ", ad_unit_id)

	var rewarded_ad_load_callback := RewardedAdLoadCallback.new()

	rewarded_ad_load_callback.on_ad_failed_to_load = func(ad_error: LoadAdError) -> void:
		is_ad_loaded = false
		is_loading = false
		print("❌ Rewarded ad failed to load: ", ad_error.message)
		print("Error code: ", ad_error.code)
		emit_signal("ad_failed_to_load")
		# Retry after delay
		print("🔄 Retrying ad load in ", AD_RETRY_DELAY, " seconds...")
		retry_timer.start()

	rewarded_ad_load_callback.on_ad_loaded = func(loaded_ad: RewardedAd) -> void:
		is_ad_loaded = true
		is_loading = false
		rewarded_ad = loaded_ad
		print("✅ Rewarded ad loaded successfully (UID: ", rewarded_ad._uid, ")")
		emit_signal("ad_loaded")

	RewardedAdLoader.new().load(ad_unit_id, AdRequest.new(), rewarded_ad_load_callback)

func show_rewarded_ad() -> void:
	print("========================================")
	print("show_rewarded_ad() called")
	print("  is_plugin_available: ", is_plugin_available)
	print("  is_ad_loaded: ", is_ad_loaded)
	print("  rewarded_ad: ", rewarded_ad)
	print("========================================")

	if not is_plugin_available:
		print("⚠️ AdMob plugin not available - granting free refill (no internet)")
		grant_free_refill()
		return

	if not is_ad_loaded or rewarded_ad == null:
		print("⚠️ Rewarded ad not loaded yet - granting free refill (no internet)")
		grant_free_refill()
		load_rewarded_ad()  # Try to load for next time
		return

	print("📺 Showing rewarded ad...")

	# Setup full screen content callbacks
	var full_screen_content_callback := FullScreenContentCallback.new()

	full_screen_content_callback.on_ad_dismissed_full_screen_content = func() -> void:
		print("🚪 Ad dismissed")
		emit_signal("ad_closed")
		# Destroy and reload next ad
		if rewarded_ad:
			rewarded_ad.destroy()
			rewarded_ad = null
			is_ad_loaded = false
		load_rewarded_ad()

	full_screen_content_callback.on_ad_failed_to_show_full_screen_content = func(ad_error: AdError) -> void:
		print("❌ Ad failed to show: ", ad_error.message)
		emit_signal("ad_failed_to_load")
		if rewarded_ad:
			rewarded_ad.destroy()
			rewarded_ad = null
			is_ad_loaded = false
		# Grant free refill if ad fails to show (no internet)
		grant_free_refill()

	rewarded_ad.full_screen_content_callback = full_screen_content_callback
	rewarded_ad.show(on_user_earned_reward_listener)

func grant_free_refill() -> void:
	print("✅ Granting free shake refill (no internet connection)")
	emit_signal("reward_earned")

# AdMob Callbacks

func _on_user_earned_reward(rewarded_item: RewardedItem) -> void:
	print("🎁 User earned reward: ", rewarded_item.amount, " ", rewarded_item.type)
	emit_signal("reward_earned")

# Timer Callbacks

func _on_retry_timeout() -> void:
	print("🔄 Retrying ad load...")
	load_rewarded_ad()

# Public API

func is_ad_ready() -> bool:
	return is_plugin_available and is_ad_loaded and rewarded_ad != null
