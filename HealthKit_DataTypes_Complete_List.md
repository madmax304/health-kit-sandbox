# Complete HealthKit Data Types Reference

## Overview

**Yes, you're correct!** Your tool calls are based on **existing HealthKit data types**. You don't create custom data types - you create functions that **query** HealthKit's predefined data types.

**Important:** HealthKit does NOT support custom data types. You work with the standardized types below.

---

## 📊 Data Type Categories

HealthKit organizes data into several categories:

1. **Quantity Types** - Numerical values (steps, heart rate, weight, etc.)
2. **Category Types** - Discrete categories (sleep stages, menstrual flow, etc.)
3. **Characteristic Types** - Static user info (date of birth, blood type, etc.)
4. **Correlation Types** - Complex multi-value data (blood pressure, food, etc.)
5. **Workout Types** - Physical activities (running, cycling, etc.)

---

## 🔢 Quantity Types (HKQuantityTypeIdentifier)

These are numerical values with units. Most common for tool calls.

### **Activity & Fitness**

| Identifier | Description | Unit | Source |
|------------|-------------|------|--------|
| `stepCount` | Steps taken | count | iPhone/Watch |
| `distanceWalkingRunning` | Walking/running distance | meters/km/miles | iPhone/Watch |
| `distanceCycling` | Cycling distance | meters/km/miles | Watch/Apps |
| `distanceWheelchair` | Wheelchair distance | meters/km/miles | Watch/Apps |
| `distanceSwimming` | Swimming distance | meters/km/yards | Watch |
| `distanceDownhillSnowSports` | Skiing/snowboarding | meters/km/miles | Watch |
| `basalEnergyBurned` | Resting calories | kcal | Watch |
| `activeEnergyBurned` | Active calories | kcal | Watch |
| `appleExerciseTime` | Exercise minutes | minutes | Watch |
| `appleStandTime` | Stand hours | hours | Watch |
| `flightsClimbed` | Flights of stairs | count | iPhone/Watch |
| `nikeFuel` | Nike Fuel points | count | Apps |
| `pushCount` | Wheelchair pushes | count | Watch |
| `swimmingStrokeCount` | Swimming strokes | count | Watch |
| `numberOfTimesFallen` | Fall detection | count | Watch |

### **Vital Signs**

| Identifier | Description | Unit | Source |
|------------|-------------|------|--------|
| `heartRate` | Heart rate | bpm (count/min) | Watch |
| `restingHeartRate` | Resting heart rate | bpm | Watch |
| `walkingHeartRateAverage` | Walking HR average | bpm | Watch |
| `heartRateVariabilitySDNN` | HRV (SDNN) | milliseconds | Watch |
| `respiratoryRate` | Breathing rate | breaths/min | Watch/Manual |
| `bodyTemperature` | Body temperature | °C/°F | Manual/Devices |
| `bloodPressureSystolic` | Systolic BP | mmHg | Devices/Manual |
| `bloodPressureDiastolic` | Diastolic BP | mmHg | Devices/Manual |
| `oxygenSaturation` | Blood oxygen (SpO₂) | % | Watch Series 6+ |
| `peripheralPerfusionIndex` | Perfusion index | % | Watch |

### **Body Measurements**

| Identifier | Description | Unit | Source |
|------------|-------------|------|--------|
| `bodyMass` | Weight | kg/lbs | Scales/Manual |
| `bodyMassIndex` | BMI | count | Calculated |
| `bodyFatPercentage` | Body fat % | % | Scales/Manual |
| `leanBodyMass` | Lean body mass | kg/lbs | Scales/Manual |
| `height` | Height | cm/inches | Manual |
| `waistCircumference` | Waist size | cm/inches | Manual |
| `headCircumference` | Head size | cm/inches | Manual |

### **Nutrition**

| Identifier | Description | Unit | Source |
|------------|-------------|------|--------|
| `dietaryEnergyConsumed` | Calories | kcal | Apps/Manual |
| `dietaryProtein` | Protein | grams | Apps/Manual |
| `dietaryCarbohydrates` | Carbs | grams | Apps/Manual |
| `dietaryFatTotal` | Total fat | grams | Apps/Manual |
| `dietaryFatSaturated` | Saturated fat | grams | Apps/Manual |
| `dietaryFatPolyunsaturated` | Polyunsaturated fat | grams | Apps/Manual |
| `dietaryFatMonounsaturated` | Monounsaturated fat | grams | Apps/Manual |
| `dietaryCholesterol` | Cholesterol | mg | Apps/Manual |
| `dietarySodium` | Sodium | mg | Apps/Manual |
| `dietarySugar` | Sugar | grams | Apps/Manual |
| `dietaryFiber` | Fiber | grams | Apps/Manual |
| `dietaryCalcium` | Calcium | mg | Apps/Manual |
| `dietaryIron` | Iron | mg | Apps/Manual |
| `dietaryThiamin` | Thiamin (B1) | mg | Apps/Manual |
| `dietaryRiboflavin` | Riboflavin (B2) | mg | Apps/Manual |
| `dietaryNiacin` | Niacin (B3) | mg | Apps/Manual |
| `dietaryFolate` | Folate | mcg | Apps/Manual |
| `dietaryBiotin` | Biotin | mcg | Apps/Manual |
| `dietaryPantothenicAcid` | Pantothenic acid | mg | Apps/Manual |
| `dietaryVitaminA` | Vitamin A | mcg | Apps/Manual |
| `dietaryVitaminB6` | Vitamin B6 | mg | Apps/Manual |
| `dietaryVitaminB12` | Vitamin B12 | mcg | Apps/Manual |
| `dietaryVitaminC` | Vitamin C | mg | Apps/Manual |
| `dietaryVitaminD` | Vitamin D | mcg | Apps/Manual |
| `dietaryVitaminE` | Vitamin E | mg | Apps/Manual |
| `dietaryVitaminK` | Vitamin K | mcg | Apps/Manual |
| `dietaryWater` | Water intake | liters/fl oz | Apps/Manual |
| `dietaryCaffeine` | Caffeine | mg | Apps/Manual |
| `dietaryManganese` | Manganese | mg | Apps/Manual |
| `dietaryCopper` | Copper | mg | Apps/Manual |
| `dietaryIodine` | Iodine | mcg | Apps/Manual |
| `dietaryMagnesium` | Magnesium | mg | Apps/Manual |
| `dietaryMolybdenum` | Molybdenum | mcg | Apps/Manual |
| `dietaryPhosphorus` | Phosphorus | mg | Apps/Manual |
| `dietaryPotassium` | Potassium | mg | Apps/Manual |
| `dietarySelenium` | Selenium | mcg | Apps/Manual |
| `dietaryZinc` | Zinc | mg | Apps/Manual |

### **Lab Results & Clinical**

| Identifier | Description | Unit | Source |
|------------|-------------|------|--------|
| `bloodGlucose` | Blood glucose | mg/dL or mmol/L | Devices/Manual |
| `insulinDelivery` | Insulin delivered | IU | Devices |
| `numberOfAlcoholicBeverages` | Alcoholic drinks | count | Manual |
| `bloodAlcoholContent` | Blood alcohol | % | Manual |
| `forcedVitalCapacity` | Lung capacity | liters | Devices |
| `forcedExpiratoryVolume1` | FEV1 | liters | Devices |
| `peakExpiratoryFlowRate` | Peak flow | L/min | Devices |

### **Reproductive Health**

| Identifier | Description | Unit | Source |
|------------|-------------|------|--------|
| `basalBodyTemperature` | Basal body temp | °C/°F | Manual/Devices |
| `cervicalMucusQuality` | Mucus quality | category | Manual |

### **Environmental**

| Identifier | Description | Unit | Source |
|------------|-------------|------|--------|
| `uvExposure` | UV exposure | count | Watch/Manual |
| `environmentalAudioExposure` | Ambient noise | dB | Watch |
| `headphoneAudioExposure` | Headphone volume | dB | AirPods/Watch |

### **Other**

| Identifier | Description | Unit | Source |
|------------|-------------|------|--------|
| `timeInDaylight` | Daylight exposure | minutes | Watch |
| `appleMoveTime` | Move minutes | minutes | Watch |
| `appleWalkingSteadiness` | Walking steadiness | % | iPhone |
| `sixMinuteWalkTestDistance` | 6-min walk test | meters | Manual |

---

## 🏷️ Category Types (HKCategoryTypeIdentifier)

Discrete categories, not numerical values.

### **Sleep**

| Identifier | Description | Values | Source |
|------------|-------------|--------|--------|
| `sleepAnalysis` | Sleep stages | asleep, inBed, awake | Watch/Apps |

**Sleep Values:**
- `asleep` - Actually sleeping
- `inBed` - In bed but may be awake
- `awake` - Awake

### **Mindfulness**

| Identifier | Description | Values | Source |
|------------|-------------|--------|--------|
| `mindfulSession` | Mindfulness/meditation | session | Apps/Manual |

### **Reproductive Health**

| Identifier | Description | Values | Source |
|------------|-------------|--------|--------|
| `menstrualFlow` | Menstrual flow | light, medium, heavy, spotting | Manual |
| `intermenstrualBleeding` | Spotting | present | Manual |
| `cervicalMucusQuality` | Mucus quality | dry, sticky, creamy, watery, eggWhite | Manual |
| `ovulationTestResult` | Ovulation test | positive, negative, indeterminate | Manual |
| `pregnancyTestResult` | Pregnancy test | positive, negative, indeterminate | Manual |
| `progesteroneTestResult` | Progesterone test | positive, negative, indeterminate | Manual |
| `sexualActivity` | Sexual activity | present | Manual |
| `contraceptive` | Contraceptive type | unspecified, none, implant, intrauterineDevice, intravaginalRing, oral, patch, vaginalBarrier | Manual |

### **Symptoms**

| Identifier | Description | Values | Source |
|------------|-------------|--------|--------|
| `abdominalCramps` | Abdominal cramps | mild, moderate, severe | Manual |
| `acne` | Acne | present | Manual |
| `appetiteChanges` | Appetite changes | decreased, increased, noChange | Manual |
| `bladderIncontinence` | Bladder issues | notApplicable, mild, moderate, severe | Manual |
| `bloating` | Bloating | mild, moderate, severe | Manual |
| `breastTenderness` | Breast tenderness | none, mild, moderate, severe | Manual |
| `chestTightnessOrPain` | Chest pain | mild, moderate, severe | Manual |
| `chills` | Chills | mild, moderate, severe | Manual |
| `constipation` | Constipation | mild, moderate, severe | Manual |
| `coughing` | Coughing | none, mild, moderate, severe | Manual |
| `diarrhea` | Diarrhea | mild, moderate, severe | Manual |
| `dizziness` | Dizziness | none, mild, moderate, severe | Manual |
| `drySkin` | Dry skin | mild, moderate, severe | Manual |
| `fainting` | Fainting | present | Manual |
| `fatigue` | Fatigue | none, mild, moderate, severe | Manual |
| `fever` | Fever | present | Manual |
| `generalizedBodyAche` | Body aches | mild, moderate, severe | Manual |
| `hairLoss` | Hair loss | mild, moderate, severe | Manual |
| `headache` | Headache | none, mild, moderate, severe | Manual |
| `heartburn` | Heartburn | mild, moderate, severe | Manual |
| `hotFlashes` | Hot flashes | mild, moderate, severe | Manual |
| `lossOfSmell` | Loss of smell | present | Manual |
| `lossOfTaste` | Loss of taste | present | Manual |
| `lowerBackPain` | Lower back pain | mild, moderate, severe | Manual |
| `memoryLapse` | Memory issues | mild, moderate, severe | Manual |
| `moodChanges` | Mood changes | present | Manual |
| `nausea` | Nausea | none, mild, moderate, severe | Manual |
| `nightSweats` | Night sweats | mild, moderate, severe | Manual |
| `pelvicPain` | Pelvic pain | mild, moderate, severe | Manual |
| `rapidPoundingOrFlutteringHeartbeat` | Heart palpitations | present | Manual |
| `runnyNose` | Runny nose | none, mild, moderate, severe | Manual |
| `shortnessOfBreath` | Shortness of breath | mild, moderate, severe | Manual |
| `sinusCongestion` | Sinus congestion | none, mild, moderate, severe | Manual |
| `skippedHeartbeat` | Skipped heartbeat | present | Manual |
| `sleepChanges` | Sleep changes | present | Manual |
| `soreThroat` | Sore throat | none, mild, moderate, severe | Manual |
| `vaginalDryness` | Vaginal dryness | mild, moderate, severe | Manual |
| `vomiting` | Vomiting | none, mild, moderate, severe | Manual |
| `wheezing` | Wheezing | present | Manual |

---

## 👤 Characteristic Types (HKCharacteristicTypeIdentifier)

Static user information (doesn't change frequently).

| Identifier | Description | Values | Source |
|------------|-------------|--------|--------|
| `biologicalSex` | Biological sex | notSet, female, male, other | Manual |
| `bloodType` | Blood type | notSet, aPositive, aNegative, bPositive, bNegative, abPositive, abNegative, oPositive, oNegative | Manual |
| `dateOfBirth` | Date of birth | Date | Manual |
| `fitzpatrickSkinType` | Skin type | I, II, III, IV, V, VI | Manual |
| `wheelchairUse` | Wheelchair use | notSet, no, yes | Manual |

---

## 🔗 Correlation Types (HKCorrelationTypeIdentifier)

Complex data with multiple related values.

| Identifier | Description | Contains | Source |
|------------|-------------|----------|--------|
| `bloodPressure` | Blood pressure | systolic + diastolic | Devices/Manual |
| `food` | Food item | nutrition data | Apps/Manual |

---

## 🏃 Workout Types (HKWorkoutActivityType)

Physical activities/exercises.

| Identifier | Description | Source |
|------------|-------------|--------|
| `americanFootball` | American football | Watch/Apps |
| `archery` | Archery | Watch/Apps |
| `australianFootball` | Australian football | Watch/Apps |
| `badminton` | Badminton | Watch/Apps |
| `barre` | Barre | Watch/Apps |
| `baseball` | Baseball | Watch/Apps |
| `basketball` | Basketball | Watch/Apps |
| `bowling` | Bowling | Watch/Apps |
| `boxing` | Boxing | Watch/Apps |
| `climbing` | Climbing | Watch/Apps |
| `cooldown` | Cooldown | Watch/Apps |
| `coreTraining` | Core training | Watch/Apps |
| `crossCountrySkiing` | Cross-country skiing | Watch/Apps |
| `crossTraining` | Cross training | Watch/Apps |
| `curling` | Curling | Watch/Apps |
| `cycling` | Cycling | Watch/Apps |
| `dance` | Dance | Watch/Apps |
| `discSports` | Disc sports | Watch/Apps |
| `downhillSkiing` | Downhill skiing | Watch/Apps |
| `elliptical` | Elliptical | Watch/Apps |
| `equestrianSports` | Equestrian | Watch/Apps |
| `fencing` | Fencing | Watch/Apps |
| `fishing` | Fishing | Watch/Apps |
| `flexibility` | Flexibility | Watch/Apps |
| `functionalStrengthTraining` | Functional strength | Watch/Apps |
| `golf` | Golf | Watch/Apps |
| `gymnastics` | Gymnastics | Watch/Apps |
| `handball` | Handball | Watch/Apps |
| `handCycling` | Hand cycling | Watch/Apps |
| `highIntensityIntervalTraining` | HIIT | Watch/Apps |
| `hiking` | Hiking | Watch/Apps |
| `hockey` | Hockey | Watch/Apps |
| `hunting` | Hunting | Watch/Apps |
| `lacrosse` | Lacrosse | Watch/Apps |
| `martialArts` | Martial arts | Watch/Apps |
| `mindAndBody` | Mind & body | Watch/Apps |
| `mixed` | Mixed | Watch/Apps |
| `paddleSports` | Paddle sports | Watch/Apps |
| `play` | Play | Watch/Apps |
| `preparationAndRecovery` | Prep & recovery | Watch/Apps |
| `racquetball` | Racquetball | Watch/Apps |
| `rowing` | Rowing | Watch/Apps |
| `rugby` | Rugby | Watch/Apps |
| `running` | Running | Watch/Apps |
| `sailing` | Sailing | Watch/Apps |
| `skatingSports` | Skating | Watch/Apps |
| `snowSports` | Snow sports | Watch/Apps |
| `soccer` | Soccer | Watch/Apps |
| `softball` | Softball | Watch/Apps |
| `squash` | Squash | Watch/Apps |
| `stairClimbing` | Stair climbing | Watch/Apps |
| `surfingSports` | Surfing | Watch/Apps |
| `swimming` | Swimming | Watch/Apps |
| `tableTennis` | Table tennis | Watch/Apps |
| `tennis` | Tennis | Watch/Apps |
| `trackAndField` | Track & field | Watch/Apps |
| `traditionalStrengthTraining` | Strength training | Watch/Apps |
| `volleyball` | Volleyball | Watch/Apps |
| `walking` | Walking | Watch/Apps |
| `waterFitness` | Water fitness | Watch/Apps |
| `waterPolo` | Water polo | Watch/Apps |
| `waterSports` | Water sports | Watch/Apps |
| `wrestling` | Wrestling | Watch/Apps |
| `yoga` | Yoga | Watch/Apps |

---

## 🎯 Recommended Tool Calls (Start Here)

Based on most common queries, start with these:

### **Essential Tools**

1. **`getSteps(startDate, endDate)`**
   - Query: `stepCount`
   - Most common query

2. **`getHeartRate(startDate, endDate)`**
   - Query: `heartRate`
   - Watch data

3. **`getSleep(startDate, endDate)`**
   - Query: `sleepAnalysis` (category)
   - Watch data

4. **`getWorkouts(startDate, endDate)`**
   - Query: `HKWorkoutType`
   - Watch data

5. **`getActiveEnergy(startDate, endDate)`**
   - Query: `activeEnergyBurned`
   - Watch data

### **Secondary Tools**

6. **`getDistance(startDate, endDate)`**
   - Query: `distanceWalkingRunning`
   - iPhone/Watch

7. **`getRestingHeartRate(startDate, endDate)`**
   - Query: `restingHeartRate`
   - Watch

8. **`getHRV(startDate, endDate)`**
   - Query: `heartRateVariabilitySDNN`
   - Watch

9. **`getFlightsClimbed(startDate, endDate)`**
   - Query: `flightsClimbed`
   - iPhone/Watch

10. **`getExerciseTime(startDate, endDate)`**
    - Query: `appleExerciseTime`
    - Watch

### **Advanced Tools (Add Later)**

- Body measurements (weight, BMI)
- Nutrition data
- Blood pressure
- Blood glucose
- Symptoms
- Reproductive health

---

## 📝 How to Use This List

### **For Tool Calls:**

1. **Pick a data type** from the list above
2. **Create a function** that queries that type:
   ```swift
   func getSteps(startDate: Date, endDate: Date) -> [StepData] {
       // Query HKQuantityTypeIdentifier.stepCount
   }
   ```

3. **Register with Foundation Models** as a tool
4. **Model can now call it** when users ask about steps

### **Example Tool Implementation:**

```swift
func getSteps(startDate: Date, endDate: Date) async -> StepData {
    let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    let predicate = HKQuery.predicateForSamples(
        withStart: startDate, 
        end: endDate, 
        options: .strictStartDate
    )
    
    // Query HealthKit
    // Return formatted data
}
```

---

## 🎯 Summary

- ✅ You use **existing HealthKit data types** (no custom types)
- ✅ Create **tool functions** that query these types
- ✅ Register tools with **Foundation Models**
- ✅ Model calls your tools when it needs data
- ✅ Start with common types (steps, heart rate, sleep, workouts)

**You're essentially creating a "query layer" on top of HealthKit's existing data types!**

