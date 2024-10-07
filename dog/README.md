# Dog API SPA


# Development
## dev machine build

```
# tested npm 10.2.4, 10.8.3
cd dog
npm ci
npx spago bundle-app
# Imagine 'open' invokes your web browser:
open index.html
```



## docker build - not tested lately
```
docker build -t dog .
docker run -i dog /bin/bash -c "npx spago bundle-app > /dev/stderr && cat index.js" > index.js
open index.html
```
### Development
```
docker run -it dog /bin/bash
```
From within this shell you can `spago repl` or what have you.






## Notes

From [A Joy of Working with JSON](https://dev.to/zelenya/a-joy-of-working-with-json-using-purescript-7l5) brought in

```
spago install yoga-json
```

