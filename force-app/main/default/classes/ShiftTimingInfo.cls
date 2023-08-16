/**
* @description Represents the timing information for shifts.
* @Author [Subba reddy]
* @Last Modified By [Sprutiraj]
* @Last Modified On [05-08-2023]
* @Modification Log:
* Ver    Date          Author        Last Modification
* 1.0    [04-08-2023]    [Subba reddy]    Initial Version
*/
public class ShiftTimingInfo {
    
    /**
* @description The start time of Shift 1.
*/
    public Time shift1StartTime { get; set; }
    
    /**
* @description The start time of Shift 2.
*/
    public Time shift2StartTime { get; set; }
    
    /**
* @description The start time of Shift 3.
*/
    public Time shift3StartTime { get; set; }
    
    /**
* @description The current time.
*/
    public Time currentTime { get; set; }
    
    /**
* @description Constructs a new instance of ShiftTimingInfo with the specified shift timings and current time.
* 
* @param builder The ShiftTimeInfoBuilder used to construct the ShiftTimingInfo object.
*/
    public ShiftTimingInfo(ShiftTimeInfoBuilder builder) {
        this.shift1StartTime = builder.shift1StartTime;
        this.shift2StartTime = builder.shift2StartTime;
        this.shift3StartTime = builder.shift3StartTime;
        this.currentTime = builder.currentTime;
    }
    
    /**
* @description Gets the start time of Shift 1.
* 
* @return The start time of Shift 1.
*/
    public Time getShift1StartTime() {
        return shift1StartTime;
    }
    
    /**
* @description Gets the start time of Shift 2.
* 
* @return The start time of Shift 2.
*/
    public Time getShift2StartTime() {
        return shift2StartTime;
    }
    
    /**
* @description Gets the start time of Shift 3.
* 
* @return The start time of Shift 3.
*/
    public Time getShift3StartTime() {
        return shift3StartTime;
    }
    
    /**
* @description Gets the current time.
* 
* @return The current time.
*/
    public Time getCurrentTime() {
        return currentTime;
    }
    
    /**
* @description The builder class to construct the ShiftTimingInfo object.
*/
    public class ShiftTimeInfoBuilder {
        private Time shift1StartTime; // Stores the start time of Shift 1.
        private Time shift2StartTime; // Stores the start time of Shift 2.
        private Time shift3StartTime; // Stores the start time of Shift 3.
        private Time currentTime; // Stores the Current Time.
        
        /**
* @description Sets the start time of Shift 1.
*
* @param shift1StartTime The start time of Shift 1 to be set.
* @return The ShiftTimeInfoBuilder instance to allow method chaining.
*/
        public ShiftTimeInfoBuilder setShift1StartTime(Time shift1StartTime) {
            this.shift1StartTime = shift1StartTime;
            return this;
        }
        
        /**
* @description Sets the start time of Shift 2.
*
* @param shift2StartTime The start time of Shift 2 to be set.
* @return The ShiftTimeInfoBuilder instance to allow method chaining.
*/
        public ShiftTimeInfoBuilder setShift2StartTime(Time shift2StartTime) {
            this.shift2StartTime = shift2StartTime;
            return this;
        }
        
        /**
* @description Sets the start time of Shift 3.
*
* @param shift3StartTime The start time of Shift 3 to be set.
* @return The ShiftTimeInfoBuilder instance to allow method chaining.
*/
        public ShiftTimeInfoBuilder setShift3StartTime(Time shift3StartTime) {
            this.shift3StartTime = shift3StartTime;
            return this;
        }
        
        /**
* @description Sets the current time.
*
* @param currentTime The current time to be set.
* @return The ShiftTimeInfoBuilder instance to allow method chaining.
*/
        public ShiftTimeInfoBuilder setCurrentTime(Time currentTime) {
            this.currentTime = currentTime;
            return this;
        }
        
        /**
* @description Constructs a new ShiftTimingInfo object using the provided builder.
* 
* @return The new ShiftTimingInfo object.
*/
        public ShiftTimingInfo build() {
            return new ShiftTimingInfo(this);
        }
    }
}