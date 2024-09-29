# Dog API SPA


## Build
### Docker Build
```
docker run -i dog /bin/bash -c "npx spago bundle-app > /dev/stderr && cat index.js" > index.js
open index.html
```

## Host System Build

```
# tested npm 10.2.4
cd <dogroot>
npm ci
npx spago bundle-app
# Imagine 'open' invokes your web browser:
open index.html
```




## Notes

From [A Joy of Working with JSON](https://dev.to/zelenya/a-joy-of-working-with-json-using-purescript-7l5) brought in

```
spago install yoga-json
```

