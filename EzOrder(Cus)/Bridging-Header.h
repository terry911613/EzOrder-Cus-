//
//  Bridging-Header.h
//  EzOrder(Cus)
//
//  Created by 李泰儀 on 2019/6/5.
//  Copyright © 2019 TerryLee. All rights reserved.
//

#ifndef Bridging_Header_h
#define Bridging_Header_h


#endif /* Bridging_Header_h */

#import <TPDirect/TPDirect.h>

   Content-Type: application/json
   x-api-key: YourPartnerKey
{
    "prime": String,
    "partner_key": String,
    "merchant_id": "merchantA",
    "details":"TapPay Test",
    "amount": 100,
    "cardholder": {
        "phone_number": "+886923456789",
        "name": "王小明",
        "email": "LittleMing@Wang.com",
        "zip_code": "100",
        "address": "台北市天龍區芝麻街1號1樓",
        "national_id": "A123456789"
    },
    "remember": true
}
