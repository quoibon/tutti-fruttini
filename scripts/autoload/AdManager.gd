extends Node

## AdManager - Handles AdMob integration for rewarded ads (Godot 4.x Poing Studios Plugin)

signal ad_loaded
signal ad_failed_to_load
signal ad_displayed
signal ad_closed
signal reward_earned
signal free_refill_ready

# Toggle between test and production ads
# Set to false for production release!
const USE_TEST_ADS: bool = true

# Production IDs
const PROD_ANDROID_REWARDED_AD_ID = "ca-app-pub-2547513308278750/3568656364"
const PROD_IOS_REWARDED_AD_ID = ""  # TODO: Add iOS Rewarded Ad ID when available

# Test IDs (for development)
const TEST_ANDROID_REWARDED_AD_ID = "ca-app-pub-3940256099942544/5224354917"
const TEST_IOS_REWARDED_AD_ID = "ca-app-pub-3940256099942544/1712485313"

# Poing Studios AdMob plugin objects
var rewarded_ad: RewardedAd = null
var rewarded_ad_loader: RewardedAdLoader = null
var rewarded_ad_load_callback := RewardedAdLoadCallback.new()
var full_screen_content_callback := FullScreenContentCallback.new()
var on_user_earned_reward_listener := OnUserEarnedRewardListener.new()

var is_ad_loaded: bool = false
var is_plugin_available: bool = false
var is_loading: bool = false

# Fallback timer system
var retry_timer: Timer
var free_refill_timer: Timer
var free_refill_timer_started: bool = false  # Track if timer was ever started

const AD_RETRY_DELAY: float = 5.0
const FREE_REFILL_DELAY: float = 30.0

func _ready() -> void:
	print("========================================")
	print("AdManager _ready() called")
	print("========================================")

	# Check if AdMob plugin is available
	check_plugin_availability()

	# Setup callbacks
	setup_callbacks()

	# Setup retry timer
	retry_timer = Timer.new()
	retry_timer.one_shot = true
	retry_timer.wait_time = AD_RETRY_DELAY
	retry_timer.timeout.connect(_on_retry_timeout)
	add_child(retry_timer)

	# Setup free refill timer (fallback)
	free_refill_timer = Timer.new()
	free_refill_timer.one_shot = true
	free_refill_timer.wait_time = FREE_REFILL_DELAY
	free_refill_timer.timeout.connect(_on_free_refill_timeout)
	add_child(free_refill_timer)

	# Initialize AdMob if available
	if is_plugin_available:
		initialize_admob()
		load_rewarded_ad()
	else:
		print("AdMob plugin not available - using fallback mode only")

func check_plugin_availability() -> void:
	# Check if plugin classes exist (Poing Studios Godot 4.x plugin)
	# The plugin defines these classes when it's loaded
	print("========================================")
	print("Platform: ", OS.get_name())
	print("Checking for RewardedAdLoader class...")
	is_plugin_available = ClassDB.class_exists("RewardedAdLoader")
	print("ClassDB.class_exists('RewardedAdLoader') = ", is_plugin_available)
	print("========================================")

	if is_plugin_available:
		print("✅ AdMob plugin detected (Poing Studios Godot 4.x)")
	else:
		print("❌ AdMob plugin not detected - using fallback mode")

func setup_callbacks() -> void:
	# Ad load callbacks
	rewarded_ad_load_callback.on_ad_loaded = _on_rewarded_ad_loaded
	rewarded_ad_load_callback.on_ad_failed_to_load = _on_rewarded_ad_failed_to_load

	# Full screen content callbacks
	full_screen_content_callback.on_ad_clicked = func() -> void:
		print("📱 Ad clicked")

	full_screen_content_callback.on_ad_dismissed_full_screen_content = func() -> void:
		print("🚪 Ad dismissed")
		emit_signal("ad_closed")
		# Destroy and reload next ad
		destroy_ad()
		load_rewarded_ad()

	full_screen_content_callback.on_ad_failed_to_show_full_screen_content = func(ad_error: AdError) -> void:
		print("❌ Ad failed to show: ", ad_error.message)
		emit_signal("ad_failed_to_load")
		destroy_ad()
		show_free_refill_option()

	full_screen_content_callback.on_ad_impression = func() -> void:
		print("👁️ Ad impression recorded")

	full_screen_content_callback.on_ad_showed_full_screen_content = func() -> void:
		print("📺 Ad displayed full screen")
		emit_signal("ad_displayed")

	# Reward callback
	on_user_earned_reward_listener.on_user_earned_reward = _on_user_earned_reward

func initialize_admob() -> void:
	if not is_plugin_available:
		return

	print("🎬 Initializing AdMob...")
	var mode = "TEST" if USE_TEST_ADS else "PRODUCTION"
	print("AdMob Mode: ", mode)

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

	# Get appropriate ad unit ID based on platform and test mode
	var ad_unit_id: String
	if OS.get_name() == "Android":
		ad_unit_id = TEST_ANDROID_REWARDED_AD_ID if USE_TEST_ADS else PROD_ANDROID_REWARDED_AD_ID
	else:
		ad_unit_id = TEST_IOS_REWARDED_AD_ID if USE_TEST_ADS else PROD_IOS_REWARDED_AD_ID

	# Load rewarded ad using new API
	print("📥 Loading rewarded ad (", "TEST" if USE_TEST_ADS else "PRODUCTION", ")...")
	print("Ad Unit ID: ", ad_unit_id)

	rewarded_ad_loader = RewardedAdLoader.new()
	rewarded_ad_loader.load(ad_unit_id, AdRequest.new(), rewarded_ad_load_callback)

func show_rewarded_ad() -> void:
	print("========================================")
	print("show_rewarded_ad() called")
	print("  is_plugin_available: ", is_plugin_available)
	print("  is_ad_loaded: ", is_ad_loaded)
	print("  rewarded_ad: ", rewarded_ad)
	print("========================================")

	if not is_plugin_available:
		print("⚠️ AdMob plugin not available - starting free refill timer")
		show_free_refill_option()
		return

	if not is_ad_loaded or rewarded_ad == null:
		print("⚠️ Rewarded ad not loaded yet - attempting to load")
		load_rewarded_ad()
		show_free_refill_option()  # Offer fallback while loading
		return

	print("📺 Showing rewarded ad...")
	rewarded_ad.show(on_user_earned_reward_listener)

func destroy_ad() -> void:
	if rewarded_ad:
		rewarded_ad.destroy()
		rewarded_ad = null
		is_ad_loaded = false
		print("🗑️ Ad destroyed")

func show_free_refill_option() -> void:
	print("⏱️ Free refill available in ", FREE_REFILL_DELAY, " seconds")
	free_refill_timer_started = true
	free_refill_timer.start()

func grant_free_refill() -> void:
	print("✅ Granting free shake refill")
	emit_signal("reward_earned")

# AdMob Callbacks (Poing Studios API)

func _on_rewarded_ad_loaded(loaded_ad: RewardedAd) -> void:
	is_ad_loaded = true
	is_loading = false
	rewarded_ad = loaded_ad
	rewarded_ad.full_screen_content_callback = full_screen_content_callback

	print("✅ Rewarded ad loaded successfully (UID: ", rewarded_ad._uid, ")")
	emit_signal("ad_loaded")

func _on_rewarded_ad_failed_to_load(ad_error: LoadAdError) -> void:
	is_ad_loaded = false
	is_loading = false
	print("❌ Rewarded ad failed to load: ", ad_error.message)
	print("Error code: ", ad_error.code)
	emit_signal("ad_failed_to_load")

	# Retry after delay
	print("🔄 Retrying ad load in ", AD_RETRY_DELAY, " seconds...")
	retry_timer.start()

	# Offer free refill as backup
	show_free_refill_option()

func _on_user_earned_reward(rewarded_item: RewardedItem) -> void:
	print("🎁 User earned reward: ", rewarded_item.amount, " ", rewarded_item.type)
	emit_signal("reward_earned")

	# Cancel free refill timer if active
	if free_refill_timer.time_left > 0:
		free_refill_timer.stop()

# Timer Callbacks

func _on_retry_timeout() -> void:
	print("🔄 Retrying ad load...")
	load_rewarded_ad()

func _on_free_refill_timeout() -> void:
	print("✅ Free refill now available!")
	emit_signal("free_refill_ready")

# Public API

func is_ad_ready() -> bool:
	return is_plugin_available and is_ad_loaded and rewarded_ad != null

func get_free_refill_time_remaining() -> float:
	return free_refill_timer.time_left

func is_free_refill_ready() -> bool:
	# Free refill is ready only if:
	# 1. Timer was started (ad failed or plugin unavailable)
	# 2. AND timer has finished (time_left = 0 and is_stopped = true)
	var ready = free_refill_timer_started and free_refill_timer.is_stopped() and free_refill_timer.time_left <= 0

	print("is_free_refill_ready() = ", ready)
	print("  timer_started=", free_refill_timer_started)
	print("  timer_stopped=", free_refill_timer.is_stopped())
	print("  time_left=", free_refill_timer.time_left)
	print("  plugin_available=", is_plugin_available)

	return ready
