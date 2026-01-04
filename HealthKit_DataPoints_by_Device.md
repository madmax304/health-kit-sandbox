# HealthKit Data Points by Device

## 📱 iPhone - Automatic Tracking

### Activity & Movement
- **Steps** - Via accelerometer
- **Walking Distance** - Estimated from steps
- **Running Distance** - Estimated from steps  
- **Walking + Running Distance** - Combined distance
- **Flights Climbed** - Via barometer (iPhone 6+)

### Limitations
- No heart rate data
- No workout detection
- No active calories (only estimates)
- No sleep stages
- Less accurate when phone is in bag/pocket

---

## ⌚ Apple Watch - Automatic Tracking

### Cardiovascular
- **Heart Rate** - Continuous monitoring (optical sensor)
- **Heart Rate Variability (HRV)** - Stress/recovery indicator
- **Resting Heart Rate** - Average during inactivity
- **Walking Heart Rate Average** - Average during walking
- **ECG (Electrocardiogram)** - Series 4+ only
- **Blood Oxygen (SpO₂)** - Series 6+ only
- **Irregular Rhythm Notifications** - Atrial fibrillation detection (Series 1+)

### Activity & Fitness
- **Active Energy** - Calories burned during activity (heart rate + motion)
- **Basal Energy** - Calories burned at rest
- **Exercise Minutes** - Automatic workout detection
- **Stand Hours** - Hours with at least 1 minute of movement
- **Workout Detection** - Automatic recognition of activities
- **Workout Types** - Running, cycling, swimming, yoga, etc.
- **Running Power** - Series 9+ (watchOS 10+)
- **Running Dynamics** - Series 9+ (watchOS 10+)
- **Cycling Power** - With compatible sensors

### Sleep
- **Sleep Analysis** - Time asleep, time in bed
- **Sleep Stages** - REM, Deep, Light, Core (Series 3+)
- **Time in Bed** - Automatic detection
- **Time Asleep** - Automatic detection

### Environmental & Safety
- **Environmental Audio Exposure** - Ambient noise levels
- **Headphone Audio Exposure** - Audio levels from AirPods/headphones
- **Handwashing Detection** - Automatic detection and timing

### Activity Rings
- **Move Ring** - Active calories
- **Exercise Ring** - Exercise minutes
- **Stand Ring** - Stand hours

---

## ✋ Manual Entry (Any Device - iPhone/iPad)

### Body Measurements
- **Weight**
- **Body Mass Index (BMI)**
- **Body Fat Percentage**
- **Lean Body Mass**
- **Waist Circumference**
- **Height**

### Vital Signs
- **Blood Pressure** (Systolic & Diastolic) - Unless using compatible device
- **Body Temperature**
- **Blood Glucose** - Unless using compatible device
- **Respiratory Rate**
- **Oxygen Saturation** - Unless using Apple Watch Series 6+

### Nutrition
- **Water Intake**
- **Dietary Energy (Calories)**
- **Dietary Protein**
- **Dietary Carbohydrates**
- **Dietary Fat**
- **Dietary Fiber**
- **Dietary Sugar**
- **Dietary Sodium**
- **Dietary Calcium**
- **Dietary Iron**
- **Dietary Vitamin A**
- **Dietary Vitamin C**
- **Dietary Vitamin D**
- **Caffeine**

### Reproductive Health
- **Menstrual Flow**
- **Cervical Mucus Quality**
- **Basal Body Temperature**
- **Ovulation Test Result**
- **Pregnancy Test Result**
- **Sexual Activity**
- **Contraceptive Type**

### Health Events & Symptoms
- **Symptoms** - Custom symptoms
- **Mood** - Various mood states
- **Mindfulness Minutes** - Meditation/mindfulness sessions
- **Pain** - Pain levels and locations
- **Headache** - Headache severity
- **Nausea** - Nausea levels
- **Dizziness** - Dizziness episodes
- **Fever** - Fever episodes

### Medications & Allergies
- **Medications** - Medication logs
- **Allergies** - Allergy records

### Medical Records (Can be imported)
- **Lab Results**
- **Immunizations**
- **Procedures**
- **Conditions**
- **Vital Signs** (from medical records)

---

## 🔌 Third-Party Devices (Can Sync to HealthKit)

### Blood Pressure Monitors
- **Blood Pressure** (Systolic & Diastolic)
- Compatible brands: iHealth, Withings, Omron, etc.

### Glucose Monitors
- **Blood Glucose**
- Compatible with: Dexcom, FreeStyle Libre, etc.

### Smart Scales
- **Weight**
- **Body Fat Percentage**
- **Lean Body Mass**
- **BMI**
- Compatible brands: Withings, Fitbit Aria, etc.

### Thermometers
- **Body Temperature**
- Compatible brands: Kinsa, Withings, etc.

### Fitness Trackers
- **Steps**
- **Distance**
- **Heart Rate**
- **Workouts**
- Compatible brands: Fitbit, Garmin, Polar, etc.

### Sleep Trackers
- **Sleep Analysis**
- **Sleep Stages**
- Compatible brands: Withings, Oura Ring, etc.

---

## 📊 Data Source Priority

When multiple sources provide the same data type, HealthKit prioritizes:

1. **Manual Entry** (Highest Priority)
2. **iPhone/Apple Watch** data
3. **Third-Party Apps**
4. **Bluetooth Devices**

Users can adjust this priority in Settings > Health > Data Access & Devices

---

## 🎯 Summary by Device Capability

### iPhone Only (No Watch Needed)
- Steps
- Walking/Running Distance
- Flights Climbed
- Basic activity tracking

### Apple Watch Required
- Heart Rate & HRV
- ECG
- Blood Oxygen
- Sleep Stages
- Active Calories (accurate)
- Exercise Minutes
- Workout Detection
- Environmental Audio

### Manual Entry (Any Device)
- Body Measurements
- Nutrition
- Reproductive Health
- Symptoms & Mood
- Medications
- Most Vital Signs (unless device)

### Third-Party Devices
- Blood Pressure
- Blood Glucose
- Body Composition (scales)
- Body Temperature
- Advanced Sleep Tracking

---

## 📝 Notes

- **iPhone tracking is less accurate** when phone is in bag/pocket
- **Apple Watch provides more accurate** activity data when worn
- **Manual entry** is always available but requires user effort
- **Third-party devices** can fill gaps in Apple device capabilities
- **Data quality varies** by device and user behavior
- **Permissions required** for each data type per app

