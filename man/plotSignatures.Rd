% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotSignatures.R
\name{plotSignatures}
\alias{plotSignatures}
\title{Plots decomposed mutational signatures or APOBEC enrichment plot.}
\usage{
plotSignatures(nmfRes = NULL, contributions = FALSE, color = NULL, ...)
}
\arguments{
\item{nmfRes}{results from \code{\link{extractSignatures}} or \code{\link{trinucleotideMatrix}}}

\item{contributions}{If TRUE plots contribution of signatures in each sample.}

\item{color}{colors for each Ti/Tv conversion class. Default NULL}

\item{...}{further plot options passed to \code{\link{barplot}}}
}
\value{
ggplot object if contributions is TRUE
}
\description{
If input is results from \code{\link{extractSignatures}} plots decomposed mutational signatures as a barplot. If input is results from \code{\link{trinucleotideMatrix}}
plots APOBEC enrichment plot.
}
\seealso{
\code{\link{trinucleotideMatrix}}
}
