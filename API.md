API
===
There is a simple json api for this application to make it easy for data
retrieval.

A couple of examples with curl:
```bash
curl -H 'Content-Type: application/json' -H 'Accept: application/json' -X GET -d '{"user":{"email":"user@example.com","password":"secret"}}' http://localhost:3000/api/products
```
```json
[{"id":33265,"product_id":"2PYROL","directory":"2PYROL","sds":"SDS - 2-PYROL.pdf","pds":"PDS - 2-Pyrol.pdf","vendor_id":"ASI ISP SINGAPORE","vendor_name":null,"description":"2-Pyrol (2 Pyrrolidone Purf)","description2":"2-Pyrol (2 Pyrrolidone Purf)","sds_expiry":"2018-07-11T00:00:00.000Z","unit_measure":"KG","shelf_life":"","inventory":"0.0","quantity_purchase_order":null,"quantity_packing_slip":null,"created_at":"2016-01-22T01:48:03.912Z","updated_at":"2016-01-22T01:48:03.912Z"}, ... ]
```
```bash
curl -H 'Content-Type: application/json' -H 'Accept: application/json' -X GET -d '{"user":{"email":"user@example.com","password":"secret"}}' http://localhost:3000/api/products/33265
```
