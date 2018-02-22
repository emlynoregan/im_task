cd src
rm -rf dist
python setup.py sdist
python setup.py bdist_wheel --universal
twine upload dist/* --skip-existing
