@isTest
public class ShiftTimingInfoTest {

    @isTest
    public static void testShiftTimingInfo() {
        // Test the ShiftTimingInfo class and its builder

        // Create a ShiftTimeInfoBuilder instance
        ShiftTimingInfo.ShiftTimeInfoBuilder builder = new ShiftTimingInfo.ShiftTimeInfoBuilder();
        Time shift1StartTime = Time.newInstance(8, 0, 0, 0); // 8:00 AM
        Time shift2StartTime = Time.newInstance(16, 0, 0, 0); // 4:00 PM
        Time shift3StartTime = Time.newInstance(23, 0, 0, 0); // 11:00 PM
        Time currentTime = Time.newInstance(12, 0, 0, 0); // 12:00 PM
        ShiftTimingInfo timingInfo = builder
            .setShift1StartTime(shift1StartTime)
            .setShift2StartTime(shift2StartTime)
            .setShift3StartTime(shift3StartTime)
            .setCurrentTime(currentTime)
            .build();

        // Test the getter methods
        System.assertEquals(shift1StartTime, timingInfo.getShift1StartTime(),'shift start time1');
        System.assertEquals(shift2StartTime, timingInfo.getShift2StartTime(),'shift start time2');
        System.assertEquals(shift3StartTime, timingInfo.getShift3StartTime(),'shift start time3');
        System.assertEquals(currentTime, timingInfo.getCurrentTime(),'Current time');
    }
}