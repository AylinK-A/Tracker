import Foundation

struct StoreUpdate {

    struct Move: Hashable {
        let oldIndexPath: IndexPath
        let newIndexPath: IndexPath
    }

    let insertedSections: IndexSet
    let deletedSections: IndexSet
    let insertedIndexPaths: Set<IndexPath>
    let deletedIndexPaths: Set<IndexPath>
    let updatedIndexPaths: Set<IndexPath>
    let movedIndexPaths: Set<Move>
}

