protocol ScheduleViewControllerDelegate: AnyObject {
    func getConfiguredSchedule(_ schedule: Set<Weekday>)
}
