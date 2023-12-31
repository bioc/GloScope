#' @title Calculate density for each sample based on reduced dimension embedding
#'
#' @description The `calc_dens` function fits separate multivariate densities to
#'   each sample. As input, the function expects a named list with names
#'   corresponding to sample IDs, and elements holding a matrix or data.frame of
#'   dimensionality reduced cells from the samples. Each matrix-type will have
#'   rows corresponding to each cell and columns corresponding to the cells
#'   projection into a latent dimension. The k-nearest neighbour algorithm does
#'   density and distance estimation in a single step, and for that `dens`
#'   specification this function simply returns the input embedding matrices
#'   (see R/calc_dist.R).
#'
#' @param df_list A list containing each samples' dimension reduction embedding
#' @param dens method used to estimate density, options are GMM (Gaussian
#'   mixture model) and KNN (k-nearest Neighbor)
#' @param k number of k nearest neighbour for KNN density estimation, default k
#'   = 50.
#' @param num_components a vector of integers for the number of components to
#'   fit GMMS to, default is seq_len(9)
#' @param BPPARAM BiocParallel parameters
#' @return mod_list: a list of length number of samples, contains the estimated
#'   density for each sample
#'
#' @importFrom BiocParallel bplapply
#' @importFrom BiocParallel bpparam
#' @importFrom mclust densityMclust
#' @noRd
.calc_dens <- function(df_list, dens = c("GMM","KNN"), k = 50, num_components = seq_len(9),
                BPPARAM = BiocParallel::bpparam()){
    dens<-match.arg(dens)
    if(dens == "GMM"){
        # run (in parallel) GMM density fitting with `mclust::densityMclust`
        mod_list <- BiocParallel::bplapply(df_list, function(z){
        mclust::densityMclust(z,
            G = get_gmm_num_components_vec(nrow(z),num_components),
            verbose = FALSE, plot = FALSE)},BPPARAM=BPPARAM)
    }else if(dens == "KNN"){
        # The KNN algorithm takes the embedding coordinates as input and does not require density estimation
        mod_list <- df_list
    }

    return(mod_list)
}
