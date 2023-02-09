library("terra")
options(timeout = 1000)
set.seed(1)

# url = "https://landsat.usgs.gov/files/C2_Sample_Data/LO08_L1TP_067017_20130722_20200925_02_T1.zip"
# download.file(url, "landsat.zip")
# unzip("landsat.zip")

start_time = Sys.time()

files = list.files("LO08_L1TP_067017_20130722_20200925_02_T1/",
                   pattern = ".+B[1-7]\\.TIF$", full.names = TRUE)
# vrt(files, "vrt.vrt", options = c("-tr", 60, 60, "-separate")) # downsample
# ras = rast("vrt.vrt")

ras = rast(files) ## scale spectral values?
names(ras) = paste0("B", 1:7)
size = round(ncell(ras) * 0.1) # take 10% of data to train
smp = spatSample(ras, size, method = "regular", na.rm = TRUE, xy = TRUE)
mdl = kmeans(smp, centers = 2000)
mdl = mdl$centers
rownames(mdl) = NULL

predict.kmeans = function(mdl, newdata) {
  # `newdata` must be matrix!!!
  vec = integer(nrow(newdata))
  mdl = t(mdl)
  seq_iter = as.integer(seq.int(1, nrow(newdata), length.out = 20))
  for (i in seq_len(nrow(newdata))) {
    vec[i] = which.min(colSums((mdl - as.numeric(newdata[i, ]))^2))
    if (i %in% seq_iter) cat(round(i / nrow(newdata) * 100), sep = "\n") # print progress
  }
  return(vec)
}

rm(smp)
df = as.data.frame(ras, xy = TRUE, na.rm = FALSE) # convert to integer matrix?
idx = which(complete.cases(df))
vec = rep(NA_integer_, ncell(ras))

pred = predict.kmeans(mdl, df[idx, ])
vec[idx] = pred
rm(df, mdl, idx)

rcl = rast(ras, nlyrs = 1, vals = vec)
rcl = focal(rcl, w = 11, fun = "modal") # smooth

end_time = Sys.time()
end_time - start_time

vect = as.polygons(rcl) # this vect has got too many verticles
# writeVector(vect, "polygons.gpkg")

plotRGB(ras, 3, 2, 1, scale = 65535, stretch = "hist")
plot(vect, border = adjustcolor("red", alpha.f = 0.4))

## downsample to 60 m
# rcl_60 = agg(rcl, fact = 2, method = "modal")

## upsample to original resolution 30 m
# rcl_30 = disagg(rcl, fact = 3, method = "near")

## simplify geometry
# vect = simplifyGeom(vect, tolerance = 30) but this create holes
