//
//  CLFIncenseCommonHeader.h
//  Incense
//
//  Created by CaiGavin on 8/22/15.
//  Copyright (c) 2015 CaiGavin. All rights reserved.
//

#ifndef Incense_CLFIncenseCommonHeader_h
#define Incense_CLFIncenseCommonHeader_h

#define Incense_Screen_Width     [UIScreen mainScreen].bounds.size.width
#define Incense_Screen_Height    [UIScreen mainScreen].bounds.size.height
#define Size_Ratio_To_iPhone6    (Incense_Screen_Height / 667.0f)
// I think the position is ok for each condition
#define Incense_Location         ((Incense_Screen_Height - 200 * Size_Ratio_To_iPhone6) * 0.425)
#define Incense_Burn_Off_Time    (20.0f)

#endif
