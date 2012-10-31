//
//  constants.h
//  eStudent
//
//  Created by Jalyna on 28.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#define CATALOG_SEMESTERS @"http://chrisrathjen.de/eStudent/index_semesters.php"
#define CATALOG_SUBJECTS @"http://chrisrathjen.de/eStudent/index_subjects.php?semester="
#define CATALOG_COURSES @"http://chrisrathjen.de/eStudent/Vorlesungsverzeichnis/%@"

#define BPO_JSON_URL @"http://chrisrathjen.de/eStudent/getFiles.php?action=regulations"
#define BPO_Regulation @"http://chrisrathjen.de/eStudent/Pruefungsordnungen/"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_IPHONE_5 ( IS_WIDESCREEN )