# HiPS Maps
HiPS maps are generated in two phases: warping a deep coadd to a HealPix projection, then rasterizing the reprojected fits file as a PNG.

For each phase, this cookie includes a pipeline file and a bps file. The pipeline file can be used to generate a qgraph or otherwise provide the task set for the bps workflow file.

## Firefly Viewer
After rasterization is complete, PNG tiles are available in object storage according to the `hips_base_uri` configuration parameter used for each rasterization task. This URI includes a bucket name and a key that matches the Butler collection used by the campaign. The entire URI is used in the RSP portal.
