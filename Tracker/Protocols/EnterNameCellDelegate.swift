protocol EnterNameCellDelegate: AnyObject {
    func enterNameCell(_ cell: EnterNameCell, didChangeText text: String)
    func updateCellLayout()
}

