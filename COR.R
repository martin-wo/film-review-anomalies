# ======================================================================
# CLASS OUTLIER RANKING
#
# (c) Luis Torgo, 2014
# ======================================================================
# Based on ORh by Luis Torgo
#
#
# ----------------------------------------------------------------------
classOutlierRanking <- function(form,data,
                                dist.mtrx=NULL,
                                use.tgt=FALSE,
                                clus=list(dist='euclidean',alg='hclust',
                                    meth='ward.D'),
                                  #   meth='single'),
                                power=1,
                                verbose=FALSE) {



  require(cluster)
  
  tgtVar <- all.vars(form)[1]
  N <- nrow(data)
  
  
  ## the columns to use for clustering
  clust.cols <- if (!use.tgt) setdiff(colnames(data),tgtVar) else colnames(data)
  
  
  # ------- Distance Calculation
  if (is.null(dist.mtrx)) {
      if (verbose) cat('COR:: Distance calculation...')
      if (power > 1) 
          dist.mtrx <- daisy(data[,clust.cols],metric=clus$dist)^power
      else
          dist.mtrx <- daisy(data[,clust.cols],metric=clus$dist)
  } 

  

  if (verbose) cat('\nCOR:: Clustering...')
  # ------- Hierarchical Clustering
  if (clus$alg != 'diana') {
    h <- do.call(clus$alg,list(dist.mtrx,method=clus$meth))
  } else {
    h <- do.call(clus$alg,list(dist.mtrx))
  }


  
  if (verbose) cat('\nCOR:: Ranking...')
  # ------- Ranking
  # This is the major step, obtain rankings based on clustering results

  # This vector will hold the ranking score of each data point
  rk2dif <- rk2same <- rep(0,N)
  groupsMembers <- list()

  for(ln in 1:nrow(h$merge)) {
      groupsMembers[[ln]] <-
          c(g1 <- if (h$merge[ln,1] < 0) -h$merge[ln,1] else groupsMembers[[h$merge[ln,1]]],
            g2 <- if (h$merge[ln,2] < 0) -h$merge[ln,2] else groupsMembers[[h$merge[ln,2]]])

      if (verbose) cat("\n\nMERGE ",ln,"\n\tMerging ",g1,"with ",g2,"\n")
      if (verbose) print(data[g1,])
      if (verbose) print(data[g2,])
      
      classDistrs <- lapply(list(g1,g2),function(g) table(data[g,tgtVar]))

      if (verbose) {cat("\tClassDistrs: ");print(classDistrs)}

      ## Oultlyingness scores for being a member of a very unbalanced cluster
      classDistrG <- table(data[groupsMembers[[ln]],tgtVar])
      classImbScores <- 1 - (classDistrG)/sum(classDistrG)
      scs <- classImbScores[data[groupsMembers[[ln]],tgtVar]]
      if (verbose) {cat("\n\tClassImbScores: "); print(classImbScores); cat("\n\tscs: "); print(scs)}
      rk2dif[groupsMembers[[ln]]] <- ifelse(rk2dif[groupsMembers[[ln]]] > scs,
                                            rk2dif[groupsMembers[[ln]]],
                                            scs)
      if(verbose) cat("\n\trk2dif:",rk2dif)

      ## Now outlyigness scores for merging with a group with much large same class population
      ## for each class which group has the smallest set of cases
      perClassSmallest <- sapply(levels(data[,tgtVar]),function(cl)
                                 which.min(c(classDistrs[[1]][cl],classDistrs[[2]][cl])))

      scsSz <- abs(classDistrs[[1]]-classDistrs[[2]])/(classDistrs[[1]]+classDistrs[[2]])
      scsSz[is.nan(scsSz)] <- 0
      if (verbose) {cat("\n\tperClassSmallest: "); print(perClassSmallest); cat("\n\tscsSz: "); print(scsSz)}

      scs <- rep(0,nlevels(data[,tgtVar]))
      scs[which(perClassSmallest==1)] <- scsSz[which(perClassSmallest==1)]
      rk2same[g1] <- ifelse(rk2same[g1] > scs[data[g1,tgtVar]],
                            rk2same[g1],
                            scs[data[g1,tgtVar]])
      scs <- rep(0,nlevels(data[,tgtVar]))
      scs[which(perClassSmallest==2)] <- scsSz[which(perClassSmallest==2)]
      rk2same[g2] <- ifelse(rk2same[g2] > scs[data[g2,tgtVar]],
                            rk2same[g2],
                            scs[data[g2,tgtVar]])
      if (verbose) cat("\n\trk2same: ",rk2same,"\n")
      
  }
  
  rkSame.outliers <- order(rk2dif,decreasing=T)
  pbSame.outliers <- rk2dif
  rkOthers.outliers <- order(rk2same,decreasing=T)
  pbOthers.outliers <- rk2same
  
  names(rkOthers.outliers) <- names(pbOthers.outliers) <-
      names(rkSame.outliers) <- names(pbSame.outliers) <- row.names(data)
  

  # ---- Now build up the list that will be returned
  if (verbose) cat('\n')
  list(rankSame.outliers=rkSame.outliers,rankOthers=rkOthers.outliers,
       probSame.outliers=pbSame.outliers, probOthers.outliers=pbOthers.outliers,
                                  # this is in the natural order and not
       hie=h,                     # outlierness order. To get the latter do
       dist=dist.mtrx)            # res$prob.outliers[res$rank.outliers]
}




##############################################################
##
## Ploting the results 
## NOTE: only works with 2-D data and assumes 1 column with X coordinates, 
## 2nd col. with Y corrdinates and 3rd col. with class label
##
## Example:
## r <- classOutlierRanking(class ~ .,data)
## plot.res(r,data)
##
plot.res <- function(cor.obj,data) {
  require(ggplot2)
  colnames(data)[1:3] <- c("x","y","class")
## LP
csv
  p <- lofactor(csv[1:2],1)

  data$probs <- paste(0:(dim(csv)-1),round(p,2),round(cor.obj$probSame.outliers,2),round(cor.obj$probOthers.outliers,2),sep="/")
## LP
  
#  data$probs <- paste(round(cor.obj$probSame.outliers,2),round(cor.obj$probOthers.outliers,2),sep="/")
  g <- ggplot(data,aes(x=x,y=y,color=class,label=probs)) + 
    geom_point(size=3) + 
    geom_text(hjust=0.5, vjust=-1) + 
    ggtitle("Id/LOF/P(Others)/P(Same)") + 
    guides(color=FALSE)
  g
}



##############################################################
##
## NOTE: STRONGLY "inspired" on ggbiplot (https://github.com/vqv/ggbiplot)
##
## Ploting the results using biplots for multivariate data sets
##
## Example:
## data(iris)
## rr <- classOutlierRanking(Species ~ .,iris)
## biPlot(iris,score=rr$probSame.outliers)
##
biPlot <- function(data,score,classCol=ncol(data), choices = 1:2, scale = 1, pc.biplot = TRUE, 
    obs.scale = 1, var.scale = 1, groups = data[,classCol], 
    ellipse = TRUE, ellipse.prob = 0.68, labels = NULL, labels.size = 3, 
    alpha = 1, var.axes = TRUE, circle = TRUE, circle.prob = 0.69, 
    varname.size = 3, varname.adjust = 1.5, varname.abbrev = FALSE, 
    ...) {
    require(ggplot2)
    require(plyr)
    require(scales)
    require(grid)
    
    tgtVar <- colnames(data)[classCol]
    logD <- log(data[,-classCol])
    pcobj <- prcomp(logD,center=TRUE,scale=TRUE)

    nobs.factor <- sqrt(nrow(pcobj$x) - 1)
    d <- pcobj$sdev
    u <- sweep(pcobj$x, 2, 1/(d * nobs.factor), FUN = "*")
    v <- pcobj$rotation
    
    choices <- pmin(choices, ncol(u))
    df.u <- as.data.frame(sweep(u[, choices], 2, d[choices]^obs.scale, 
        FUN = "*"))
    v <- sweep(v, 2, d^var.scale, FUN = "*")
    df.v <- as.data.frame(v[, choices])
    names(df.u) <- c("xvar", "yvar")
    names(df.v) <- names(df.u)
    if (pc.biplot) {
        df.u <- df.u * nobs.factor
    }
    r <- sqrt(qchisq(circle.prob, df = 2)) * prod(colMeans(df.u^2))^(1/4)
    v.scale <- rowSums(v^2)
    df.v <- r * df.v/sqrt(max(v.scale))
    if (obs.scale == 0) {
        u.axis.labs <- paste("standardized PC", choices, sep = "")
    }
    else {
        u.axis.labs <- paste("PC", choices, sep = "")
    }
    u.axis.labs <- paste(u.axis.labs, sprintf("(%0.1f%% explained var.)", 
        100 * pcobj$sdev[choices]^2/sum(pcobj$sdev^2)))
    if (!is.null(labels)) {
        df.u$labels <- labels
    }
    if (!is.null(groups)) {
        df.u$groups <- groups
    }
    if (varname.abbrev) {
        df.v$varname <- abbreviate(rownames(v))
    }
    else {
        df.v$varname <- rownames(v)
    }
    df.v$angle <- with(df.v, (180/pi) * atan(yvar/xvar))
    df.v$hjust = with(df.v, (1 - varname.adjust * sign(xvar))/2)
    df.u$score <- score
    g <- ggplot(data = df.u, aes(x = xvar, y = yvar)) + xlab(u.axis.labs[1]) + 
        ylab(u.axis.labs[2]) + coord_equal()
    if (var.axes) {
        if (circle) {
            theta <- c(seq(-pi, pi, length = 50), seq(pi, -pi, 
                length = 50))
            circle <- data.frame(xvar = r * cos(theta), yvar = r * 
                sin(theta))
            g <- g + geom_path(data = circle, color = muted("white"), 
                size = 1/2, alpha = 1/3)
        }
        g <- g + geom_segment(data = df.v, aes(x = 0, y = 0, 
            xend = xvar, yend = yvar), arrow = arrow(length = unit(1/2, 
            "picas")), color = muted("red"))
    }
    if (!is.null(df.u$labels)) {
        if (!is.null(df.u$groups)) {
            g <- g + geom_text(aes(label = labels, color = groups), 
                size = labels.size)
        }
        else {
            g <- g + geom_text(aes(label = labels), size = labels.size)
        }
    }
    else {
        if (!is.null(df.u$groups)) {
            g <- g + geom_point(aes(color = groups,size=score))
        }
        else {
            g <- g + geom_point(size=score)
        }
    }
    if (!is.null(df.u$groups) && ellipse) {
        theta <- c(seq(-pi, pi, length = 50), seq(pi, -pi, length = 50))
        circle <- cbind(cos(theta), sin(theta))
        ell <- ddply(df.u, "groups", function(x) {
            if (nrow(x) <= 2) {
                return(NULL)
            }
            sigma <- var(cbind(x$xvar, x$yvar))
            mu <- c(mean(x$xvar), mean(x$yvar))
            ed <- sqrt(qchisq(ellipse.prob, df = 2))
            data.frame(sweep(circle %*% chol(sigma) * ed, 2, 
                mu, FUN = "+"), groups = x$groups[1])
        })
        names(ell)[1:2] <- c("xvar", "yvar")
        g <- g + geom_path(data = ell, aes(color = groups, group = groups))
    }
    if (var.axes) {
        g <- g + geom_text(data = df.v, aes(label = varname, 
            x = xvar, y = yvar, angle = angle, hjust = hjust), 
            color = "darkred", size = varname.size)
    }
    return(g)
}
    



ggbiplot <- 
function (pcobj, choices = 1:2, scale = 1, pc.biplot = TRUE, 
    obs.scale = 1 - scale, var.scale = scale, groups = NULL, 
    ellipse = FALSE, ellipse.prob = 0.68, labels = NULL, labels.size = 3, 
    alpha = 1, var.axes = TRUE, circle = FALSE, circle.prob = 0.69, 
    varname.size = 3, varname.adjust = 1.5, varname.abbrev = FALSE, 
    ...) 
{
    library(ggplot2)
    library(plyr)
    library(scales)
    library(grid)
    stopifnot(length(choices) == 2)
    if (inherits(pcobj, "prcomp")) {
        nobs.factor <- sqrt(nrow(pcobj$x) - 1)
        d <- pcobj$sdev
        u <- sweep(pcobj$x, 2, 1/(d * nobs.factor), FUN = "*")
        v <- pcobj$rotation
    }
    else if (inherits(pcobj, "princomp")) {
        nobs.factor <- sqrt(pcobj$n.obs)
        d <- pcobj$sdev
        u <- sweep(pcobj$scores, 2, 1/(d * nobs.factor), FUN = "*")
        v <- pcobj$loadings
    }
    else if (inherits(pcobj, "PCA")) {
        nobs.factor <- sqrt(nrow(pcobj$call$X))
        d <- unlist(sqrt(pcobj$eig)[1])
        u <- sweep(pcobj$ind$coord, 2, 1/(d * nobs.factor), FUN = "*")
        v <- sweep(pcobj$var$coord, 2, sqrt(pcobj$eig[1:ncol(pcobj$var$coord), 
            1]), FUN = "/")
    }
    else if (inherits(pcobj, "lda")) {
        nobs.factor <- sqrt(pcobj$N)
        d <- pcobj$svd
        u <- predict(pcobj)$x/nobs.factor
        v <- pcobj$scaling
        d.total <- sum(d^2)
    }
    else {
        stop("Expected a object of class prcomp, princomp, PCA, or lda")
    }
    choices <- pmin(choices, ncol(u))
    df.u <- as.data.frame(sweep(u[, choices], 2, d[choices]^obs.scale, 
        FUN = "*"))
    v <- sweep(v, 2, d^var.scale, FUN = "*")
    df.v <- as.data.frame(v[, choices])
    names(df.u) <- c("xvar", "yvar")
    names(df.v) <- names(df.u)
    if (pc.biplot) {
        df.u <- df.u * nobs.factor
    }
    r <- sqrt(qchisq(circle.prob, df = 2)) * prod(colMeans(df.u^2))^(1/4)
    v.scale <- rowSums(v^2)
    df.v <- r * df.v/sqrt(max(v.scale))
    if (obs.scale == 0) {
        u.axis.labs <- paste("standardized PC", choices, sep = "")
    }
    else {
        u.axis.labs <- paste("PC", choices, sep = "")
    }
    u.axis.labs <- paste(u.axis.labs, sprintf("(%0.1f%% explained var.)", 
        100 * pcobj$sdev[choices]^2/sum(pcobj$sdev^2)))
    if (!is.null(labels)) {
        df.u$labels <- labels
    }
    if (!is.null(groups)) {
        df.u$groups <- groups
    }
    if (varname.abbrev) {
        df.v$varname <- abbreviate(rownames(v))
    }
    else {
        df.v$varname <- rownames(v)
    }
    df.v$angle <- with(df.v, (180/pi) * atan(yvar/xvar))
    df.v$hjust = with(df.v, (1 - varname.adjust * sign(xvar))/2)
    g <- ggplot(data = df.u, aes(x = xvar, y = yvar)) + xlab(u.axis.labs[1]) + 
        ylab(u.axis.labs[2]) + coord_equal()
    if (var.axes) {
        if (circle) {
            theta <- c(seq(-pi, pi, length = 50), seq(pi, -pi, 
                length = 50))
            circle <- data.frame(xvar = r * cos(theta), yvar = r * 
                sin(theta))
            g <- g + geom_path(data = circle, color = muted("white"), 
                size = 1/2, alpha = 1/3)
        }
        g <- g + geom_segment(data = df.v, aes(x = 0, y = 0, 
            xend = xvar, yend = yvar), arrow = arrow(length = unit(1/2, 
            "picas")), color = muted("red"))
    }
    if (!is.null(df.u$labels)) {
        if (!is.null(df.u$groups)) {
            g <- g + geom_text(aes(label = labels, color = groups), 
                size = labels.size)
        }
        else {
            g <- g + geom_text(aes(label = labels), size = labels.size)
        }
    }
    else {
        if (!is.null(df.u$groups)) {
            g <- g + geom_point(aes(color = groups), alpha = alpha)
        }
        else {
            g <- g + geom_point(alpha = alpha)
        }
    }
    if (!is.null(df.u$groups) && ellipse) {
        theta <- c(seq(-pi, pi, length = 50), seq(pi, -pi, length = 50))
        circle <- cbind(cos(theta), sin(theta))
        ell <- ddply(df.u, "groups", function(x) {
            if (nrow(x) <= 2) {
                return(NULL)
            }
            sigma <- var(cbind(x$xvar, x$yvar))
            mu <- c(mean(x$xvar), mean(x$yvar))
            ed <- sqrt(qchisq(ellipse.prob, df = 2))
            data.frame(sweep(circle %*% chol(sigma) * ed, 2, 
                mu, FUN = "+"), groups = x$groups[1])
        })
        names(ell)[1:2] <- c("xvar", "yvar")
        g <- g + geom_path(data = ell, aes(color = groups, group = groups))
    }
    if (var.axes) {
        g <- g + geom_text(data = df.v, aes(label = varname, 
            x = xvar, y = yvar, angle = angle, hjust = hjust), 
            color = "darkred", size = varname.size)
    }
    return(g)
}


## Tmp working part of program by Matej Vanek
data <- read.csv("lsa_test_normalized_informative_pca.csv")
sink("cor.out")
rr <- classOutlierRanking(stars ~ .,data,verbose=TRUE)
print(rr)
sink()
