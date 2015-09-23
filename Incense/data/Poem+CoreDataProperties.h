//
//  Poem+CoreDataProperties.h
//  Incense
//
//  Created by CaiGavin on 9/23/15.
//  Copyright © 2015 CaiGavin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Poem.h"

NS_ASSUME_NONNULL_BEGIN

@interface Poem (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *author;
@property (nullable, nonatomic, retain) NSString *firstline;
@property (nullable, nonatomic, retain) NSString *secondline;
@property (nullable, nonatomic, retain) NSNumber *poemid;

@end

NS_ASSUME_NONNULL_END
