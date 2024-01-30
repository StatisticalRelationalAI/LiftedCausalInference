library(ggplot2)
library(dplyr)
library(patchwork)
library(stringr)
library(tikzDevice)

use_tikz = FALSE

data = read.csv(file = "merged.csv", sep=",", dec=".")

data["algo"][data["algo"] == "fove.LiftedVarElim"] = "Lifted Variable Elimination (PCFG)"
data["algo"][data["algo"] == "ve.VarElimEngine"] = "Variable Elimination (FG)"
data["algo"][data["algo"] == "BN"] = "Variable Elimination (BN)"

data = rename(data, "Algorithm" = "algo")

x_level <- c(8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096)

if (use_tikz) {
  tikz("plot-eval.tex", standAlone = FALSE, height = 1.8, width = 4.0)
} else {
  pdf(file = "plot-eval.pdf", height = 2.8, width = 5.5)
}

p <- ggplot(data, aes(x=factor(dom_size, level=x_level), y=time, group=Algorithm, color=Algorithm)) +
	geom_line(aes(group=Algorithm, linetype=Algorithm, color=Algorithm)) +
	geom_point(aes(group=Algorithm, shape=Algorithm, color=Algorithm)) +
	xlab("$d$") +
	ylab("time (ms)") +
	scale_y_log10() +
	theme_classic() +
	theme(
		axis.line.x = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
		axis.line.y = element_line(arrow = grid::arrow(length = unit(0.1, "cm"))),
		legend.position = c(0.32, 0.75),
		legend.title = element_blank(),
		legend.text = element_text(size=8),
		legend.background = element_rect(fill = NA),
		legend.spacing.y = unit(0, 'mm')
	) +
	scale_color_manual(values=c(
		rgb(247,192,26, maxColorValue=255),
		rgb(78,155,133, maxColorValue=255),
		rgb(37,122,164, maxColorValue=255)
	))

p

dev.off()