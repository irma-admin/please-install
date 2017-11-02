From <https://public.kitware.com/pipermail/paraview/2017-June/040319.html>, solve installation issue with:

```
cd /data/software/sources/paraview/5.4.1-py3/gcc-6.4.0/openmpi-1.10.7/paraview-5.4.1-py3-build/lib/site-packages/__pycache__/
mv six.cpython-35.pyc ../six.pyc
mv six.cpython-35.opt-1.pyc ../six.pyo
```

then go back to installation script directory and type:

```
./install.sh
```

once again
