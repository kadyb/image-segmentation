library("terra")
set.seed(1)

## download data
url = "https://github.com/Nowosad/supercells/raw/master/inst/raster/ortho.tif"
tmp = tempfile(fileext = ".tif")
download.file(url, tmp, mode = "wb")

ortho = rast(tmp)
df = as.data.frame(ortho, xy = TRUE, na.rm = FALSE)
idx = which(complete.cases(df))

## without data scaling X and Y have more influence on the results in kmeans
# df_omit = scale(df[idx, ])
df_omit = df[idx, ]

mdl = kmeans(df_omit, centers = 500)

vec = rep(NA_integer_, ncell(ortho))
vec[idx] = mdl$cluster
rcl = rast(ortho, nlyrs = 1, vals = vec)

rcl = focal(rcl, w = 7, fun = "modal") # smooth

vect = as.polygons(rcl)

plot(ortho)
plot(vect, add = TRUE)
