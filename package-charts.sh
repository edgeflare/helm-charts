pushd charts
rm -rf *.tgz
for i in $(ls -d */); do helm package $i; done
helm repo index .
popd

mkdir -p dist
mv charts/*.tgz charts/index.yaml dist/
