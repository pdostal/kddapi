# KDD API
- Send HTTP request
- Get XML output

## Searching
GET '/search'
- user
- pass
- kind
- query

```
/search?user=XXX&kind=XXX&pass=XXX&query=XXX
```

- kind = { nazev | autor | nakladatelstvi | anotace | vse }
- kind = { nazev_preklad | klicova slova | autor neprimy | isbn }
