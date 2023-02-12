library("terra")

predict.kmeans = function(mdl, newdata) {
  # `newdata` must be matrix!!!
  vec = integer(nrow(newdata))
  mdl = t(mdl)
  for (i in seq_len(nrow(newdata))) {
    vec[i] = which.min(colSums((mdl - newdata[i, ])^2))
  }
  return(vec)
}

start_time = Sys.time()

files = list.files("LO08_L1TP_067017_20130722_20200925_02_T1/",
                   pattern = ".+B[1-7]\\.TIF$", full.names = TRUE)
ras = rast(files)
names(ras) = paste0("B", 1:7)

blocks = aggregate(rast(ras), c(1000, 1000))
blocks = as.polygons(blocks)
## it would be better to keep only vector with
## clusters (integers) instead of list of rasters
output = vector("list", length = nrow(blocks))

for (i in seq_len(nrow(blocks))) {

  cat(i , "/", nrow(blocks), "\n")
  crp = crop(ras, blocks[i, ]) # scale spectral values??
  size = round(ncell(crp) * 0.3) # take 30% of data to train

  smp = spatSample(crp, size, method = "regular", na.rm = TRUE, xy = TRUE)
  if (nrow(smp) == 0) {
    output[[i]] = rast(crp, nlyrs = 1)
    next
  }

  # number of rows can't be less than the number of clusters
  clusters = 500L
  if (nrow(smp) < clusters) clusters = as.integer(nrow(smp) * 0.1)
  mdl = suppressWarnings(kmeans(smp, centers = clusters))
  mdl = mdl$centers
  rownames(mdl) = NULL

  df = as.matrix(as.data.frame(crp, xy = TRUE, na.rm = FALSE))
  idx = which(complete.cases(df))
  vec = rep(NA_integer_, ncell(crp))

  pred = predict.kmeans(mdl, df[idx, ])
  vec[idx] = pred + clusters * i # fix cluster numbers
  output[[i]] = rast(crp, nlyrs = 1, vals = vec)

}

output = merge(sprc(output))
output = focal(output, w = 9, fun = "modal") # smooth

end_time = Sys.time()
end_time - start_time #> 18.14183 mins

vect = as.polygons(output)
# writeVector(vect, "polygons.gpkg")
