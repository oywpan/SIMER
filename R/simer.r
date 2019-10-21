# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


#' Main function of simer
#'
#' Build date: Jan 7, 2019
#' Last update: Oct 13, 2019
#'
#' @author Dong Yin, Lilin Yin, Haohao Zhang and Xiaolei Liu
#'
#' @param num.gen number of generations in simulation
#' @param replication replication index of simulation
#' @param verbose whether to print detail
#' @param mrk.dense whether markers are dense
#' @param out path of output files
#' @param out.format format of output, "numeric" or "plink"
#' @param seed.geno random seed of genotype matrix
#' @param seed.map random seed of map file
#' @param out.geno.gen indice of generation of output genotype
#' @param out.pheno.gen indice of generation of  output phenotype
#' @param rawgeno1 extrinsic genotype matrix1
#' @param rawgeno2 extrinsic genotype matrix2
#' @param rawgeno3 extrinsic genotype matrix3
#' @param rawgeno4 extrinsic genotype matrix4
#' @param num.ind population size of base population
#' @param prob weight of "0" and "1" in genotype matrix, the sum of element in vector equals 1
#' @param input.map map from outside
#' @param len.block length of every blocks
#' @param range.hot range of exchages in hot spot block
#' @param range.cold range of exchages in cold spot block
#' @param rate.mut mutation rate between 1e-8 and 1e-6
#' @param cal.model phenotype model with "A", "AD", "ADI"
#' @param h2.tr1 heritability vector of trait1, corresponding to a, d, aXa, aXd, dXa, dXd
#' @param num.qtn.tr1 integer or integer vector, the number of QTN in the trait1
#' @param var.tr1 variances of different effects, the last 5 vector elements are corrresponding to d, aXa, aXd, dXa, dXd respectively and the rest elements are corresponding to a
#' @param dist.qtn.tr1 distribution of QTN's effects with options: "normal", "geometry" and "gamma", vector elements are corresponding to a, d, aXa, aXd, dXa, dXd respectively
#' @param eff.unit.tr1 unit effect of geometric distribution of trait1, vector elements are corresponding to a, d, aXa, aXd, dXa, dXd respectively
#' @param shape.tr1 shape of gamma distribution of trait1, vector elements are corresponding to a, d, aXa, aXd, dXa, dXd respectively
#' @param scale.tr1 scale of gamma distribution of trait1, vector elements are corresponding to a, d, aXa, aXd, dXa, dXd respectively
#' @param multrait whether applying pair traits with overlapping, TRUE represents applying, FALSE represents not
#' @param num.qtn.trn QTN distribution matrix, diagnal elements are total QTN number of the trait, non-diagnal are QTN number of overlop qtn
#' @param eff.sd a matrix with the standard deviation of QTN effects
#' @param gnt.cov genetic covaiance matrix among all traits
#' @param env.cov environment covaiance matrix among all traits
#' @param qtn.spot QTN probability in every blocks
#' @param maf Minor Allele Frequency, markers selection range is from  maf to 0.5
#' @param sel.crit selection criteria with options: "TGV", "TBV", "pEBVs", "gEBVs", "ssEBVs", "pheno"
#' @param sel.on whether to add selection
#' @param mtd.reprod different reproduction methods with options: "clone", "dh", "selfpol", "singcro", "tricro", "doubcro", "backcro","randmate", "randexself" and "userped"
#' @param userped user-specific pedigree
#' @param num.prog litter size of dams
#' @param ratio ratio of males in all individuals
#' @param prog.tri litter size of the first single cross process in trible cross process
#' @param prog.doub litter size of the first two single cross process in double cross process
#' @param prog.back a vector with litter size in every generations
#' @param ps fraction selected in selection
#' @param decr whether to sorting with descreasing
#' @param sel.multi selection method of multi-trait with options: "tdm", "indcul" and "index"
#' @param index.wt economic weights of selection index method
#' @param index.tdm index represents which trait is being selected. NOT CONTROL BY USER
#' @param goal.perc percentage of goal more than mean of scores of individuals
#' @param pass.perc percentage of expected excellent individuals
#' @param sel.sing selection method of single trait with options: "ind", "fam", "infam" and "comb"
#'
#' @return a list with population information, genotype matrix, map information, selection intensity
#' @export
#' @import MASS bigmemory rMVP
#' @importFrom stats aov cor dnorm qnorm rgamma rnorm runif var
#' @importFrom utils write.table read.delim packageVersion
#' @importFrom methods getPackageName
#'
#' @examples
#' \donttest{
#' # get map file, map is neccessary
#' data(simdata)
#'
#' # run simer
#' simer.list <-
#'      simer(num.gen = 10,
#'            replication = 1,
#'            verbose = TRUE, 
#'            mrk.dense = FALSE,
#'            out = NULL,
#'            out.format = "numeric",
#'            seed.geno = runif(1, 0, 100),
#'            seed.map = 12345,
#'            out.geno.gen = 3:5,
#'            out.pheno.gen = 1:5,
#'            rawgeno1 = rawgeno,
#'            rawgeno2 = NULL,
#'            rawgeno3 = NULL,
#'            rawgeno4 = NULL,
#'            num.ind = NULL,
#'            prob = c(0.5, 0.5),
#'            input.map = input.map,
#'            len.block = 5e7,
#'            range.hot = 4:6,
#'            range.cold = 1:5,
#'            rate.mut = 1e-8,
#'            cal.model = "A",
#'            h2.tr1 = 0.3,
#'            num.qtn.tr1 = 18,
#'            var.tr1 = 2,
#'            dist.qtn.tr1 = "normal",
#'            eff.unit.tr1 = 0.5,
#'            shape.tr1 = 1,
#'            scale.tr1 = 1,
#'            multrait = FALSE,
#'            num.qtn.trn = matrix(c(18, 10, 10, 20), 2, 2),
#'            eff.sd = matrix(c(1, 0, 0, 2), 2, 2),
#'            gnt.cov = matrix(c(1, 2, 2, 15), 2, 2),
#'            env.cov = matrix(c(10, 5, 5, 100), 2, 2),
#'            qtn.spot = rep(0.1, 10),
#'            maf = 0,
#'            sel.crit = "pheno",
#'            sel.on = TRUE, 
#'            mtd.reprod = "randmate",
#'            userped = userped,
#'            num.prog = 2,
#'            ratio = 0.5,
#'            prog.tri = 2,
#'            prog.doub = 2,
#'            prog.back = rep(2, 5),
#'            ps = 0.8,
#'            decr = TRUE,
#'            sel.multi = "index",
#'            index.wt = c(0.5, 0.5),
#'            index.tdm = 1,
#'            goal.perc = 0.1,
#'            pass.perc = 0.9, 
#'            sel.sing = "comb") 
#' pop <- simer.list$pop
#' effs <- simer.list$effs
#' trait <- simer.list$trait
#' geno <- simer.list$geno
#' map <- simer.list$map
#' si <- simer.list$si
#' str(pop)
#' str(geno[])
#' str(map)
#' si
#' }
simer <-
    function(num.gen = 5,
             replication = 1,
             verbose = TRUE, 
             mrk.dense = FALSE,
             out = NULL,
             out.format = "numeric",
             seed.geno = runif(1, 0, 100),
             seed.map = 12345,
             out.geno.gen = (num.gen-2):num.gen,
             out.pheno.gen = 1:num.gen,
             rawgeno1 = NULL,
             rawgeno2 = NULL,
             rawgeno3 = NULL,
             rawgeno4 = NULL,
             num.ind = 100,
             prob = c(0.5, 0.5),
             input.map = NULL,
             len.block = 5e7,
             range.hot = 4:6,
             range.cold = 1:5,
             rate.mut = 1e-8,
             cal.model = "A",
             h2.tr1 = 0.3,
             num.qtn.tr1 = 18,
             var.tr1 = 2,
             dist.qtn.tr1 = "normal",
             eff.unit.tr1 = 0.5,
             shape.tr1 = 1,
             scale.tr1 = 1,
             multrait = FALSE,
             num.qtn.trn = matrix(c(18, 10, 10, 20), 2, 2),
             eff.sd = matrix(c(1, 0, 0, 2), 2, 2),
             gnt.cov = matrix(c(14, 10, 10, 15), 2, 2),
             env.cov = matrix(c(6, 5, 5, 10), 2, 2),
             qtn.spot = rep(0.1, 10),
             maf = 0,
             sel.crit = "pheno",
             sel.on = TRUE, 
             mtd.reprod = "randmate",
             userped = NULL,
             num.prog = 2,
             ratio = 0.5,
             prog.tri = 2,
             prog.doub = 2,
             prog.back = rep(2, num.gen),
             ps = 0.8,
             decr = TRUE,
             sel.multi = "index",
             index.wt = c(0.5, 0.5),
             index.tdm = 1,
             goal.perc = 0.1,
             pass.perc = 0.9,
             sel.sing = "comb") {

# Start simer

# TODO: How to generate inbreeding sirs and uninbreeding dams
# TODO: optcontri.sel
# TODO: add MVP for output
# TODO: correct pedigree     
# TODO: add superior limit of homo   
# TODO: add multiple fix and random effects
# TODO: add summary() to population information
# TODO: add inbreeding coeficient
# TODO: updata index selection
# TODO: add true block distribution   
  
  simer.Version(width = 70, verbose = verbose)    
      
  inner.env <- environment()    
  # initialize logging
  if (!is.null(out)) {
    if (!dir.exists(out)) stop(paste0("Please check your output path: ", out))
    if (verbose) {
      logging.initialize("Simer", out = out)
    }
  }
  
	################### MAIN_FUNCTION_SETTING ###################
  logging.log("--------------------------- replication ", replication, "---------------------------\n", verbose = verbose)
  op <- Sys.time()
  logging.log("SIMER BEGIN AT", as.character(op), "\n", verbose = verbose)
  set.seed(seed.geno)
  trait <- lapply(1:num.gen, function(i) { return(NULL) })
  names(trait) <- paste("gen", 1:num.gen, sep = "")

	################### BASE_POPULATION ###################
  # stablish genotype of base population if there isn't by two ways:
  # 1. input rawgeno
  # 2. input num.marker and num.ind
  num.marker <- nrow(input.map)
  logging.log("---base population1---\n", verbose = verbose)
  basepop.geno <-
      genotype(rawgeno = rawgeno1,
               num.marker = num.marker,
               num.ind = num.ind,
               prob = prob, 
               verbose = verbose)

  # set block information and recombination information
  nmrk <- nrow(basepop.geno)
  nind <- ncol(basepop.geno) / 2
  num.ind <- nind
  pos.map <- check.map(input.map = input.map, num.marker = nmrk, len.block = len.block)
  blk.rg <- cal.blk(pos.map)
  recom.spot <- as.numeric(pos.map[blk.rg[, 1], 7])

  # set base population information
  basepop <- getpop(nind, 1, ratio)

  # calculate for marker information
  effs <-
    cal.effs(pop.geno = basepop.geno,
             cal.model = cal.model,
             num.qtn.tr1 = num.qtn.tr1,
             var.tr1 = var.tr1,
             dist.qtn.tr1 = dist.qtn.tr1,
             eff.unit.tr1 = eff.unit.tr1,
             shape.tr1 = shape.tr1,
             scale.tr1 = scale.tr1,
             multrait = multrait,
             num.qtn.trn = num.qtn.trn,
             eff.sd = eff.sd,
             qtn.spot = qtn.spot,
             maf = maf, 
             verbose = verbose)

  # calculate phenotype according to genotype
  if (sel.on) {
    pop1.pheno <-
      phenotype(effs = effs,
                pop = basepop,
                pop.geno = basepop.geno,
                pos.map = pos.map,
                h2.tr1 = h2.tr1,
                gnt.cov = gnt.cov,
                env.cov = env.cov,
                sel.crit = sel.crit, 
                pop.total = basepop, 
                sel.on = sel.on, 
                inner.env =  inner.env, 
                verbose = verbose)
    basepop <- set.pheno(basepop, pop1.pheno, sel.crit)
    trait[[1]] <- pop1.pheno
  }
  
  # only mutation in clone and doubled haploid
  if (mtd.reprod == "clone" || mtd.reprod == "dh" || mtd.reprod == "selfpol") {
    basepop$sex <- 0
    recom.spot <- NULL
    ratio <- 0
  }
  
  basepop.geno.em <-  # genotype matrix after Mutation
    genotype(geno = basepop.geno,
             blk.rg = blk.rg,
             recom.spot = recom.spot,
             range.hot = range.hot,
             range.cold = range.cold,
             rate.mut = rate.mut, 
             verbose = verbose)

  if (mtd.reprod == "singcro" || mtd.reprod == "tricro" || mtd.reprod == "doubcro" || mtd.reprod == "backcro") {
    # set base population information
    basepop$sex <- 1

    if (is.null(rawgeno2)) {
      logging.log("---base population2---\n", verbose = verbose)
      prob1 <- runif(1)
      prob <- c(prob1, 1 - prob1)
      pop2.geno <- genotype(num.marker = num.marker, num.ind = num.ind, prob = prob, verbose = verbose)
    } else {
      pop2.geno <- genotype(rawgeno = rawgeno2, verbose = verbose)
    }

    # set base population information
    nind2 <- ncol(pop2.geno) / 2
    pop2 <- getpop(nind2, nind+1, 0)
    
    # calculate phenotype according to genotype
    if (sel.on) {
      pop2.pheno <-
        phenotype(effs = effs,
                  pop = pop2,
                  pop.geno = pop2.geno,
                  pos.map = pos.map,
                  h2.tr1 = h2.tr1,
                  gnt.cov = gnt.cov,
                  env.cov = env.cov,
                  sel.crit = sel.crit, 
                  pop.total = pop2, 
                  sel.on = sel.on, 
                  inner.env =  inner.env, 
                  verbose = verbose)
      pop2 <- set.pheno(pop2, pop2.pheno, sel.crit)
      
      # reset trait
      if (mtd.reprod != "backcro") {
        pop.sir1 <- trait[[1]]
        trait <- list()
        trait$pop.sir1 <- pop.sir1
        trait$pop.dam1 <- pop2.pheno
      } else {
        trait[[1]] <- list(pop.sir1 = trait[[1]], pop.dam1 = pop2.pheno)
      }
    }
    
    pop2.geno.em <- # genotype matrix after Mutation
          genotype(geno = pop2.geno,
                   blk.rg = blk.rg,
                   recom.spot = recom.spot,
                   range.hot = range.hot,
                   range.cold = range.cold,
                   # recom.cri = "cri3",
                   rate.mut = rate.mut, 
                   verbose = verbose)
    pop3.geno.em <- NULL
    pop4.geno.em <- NULL
  }

  if (mtd.reprod == "tricro" || mtd.reprod == "doubcro") {
    if (is.null(rawgeno3)) {
      logging.log("---base population3---\n", verbose = verbose)
      prob1 <- runif(1)
      prob <- c(prob1, 1 - prob1)
      pop3.geno <- genotype(num.marker = num.marker, num.ind = num.ind, prob = prob, verbose = verbose)
    } else {
      pop3.geno <- genotype(rawgeno = rawgeno3, verbose = verbose)
    }

    # set base population information
    nind3 <- ncol(pop3.geno) / 2
    pop3 <- getpop(nind3, nind+nind2+1, 1)
    
    # calculate phenotype according to genotype
    if (sel.on) {
      pop3.pheno <-
        phenotype(effs = effs,
                  pop = pop3,
                  pop.geno = pop3.geno,
                  pos.map = pos.map,
                  h2.tr1 = h2.tr1,
                  gnt.cov = gnt.cov,
                  env.cov = env.cov,
                  sel.crit = sel.crit, 
                  pop.total = pop3, 
                  sel.on = sel.on, 
                  inner.env =  inner.env, 
                  verbose = verbose)
      pop3 <- set.pheno(pop3, pop3.pheno, sel.crit)
      trait$pop.sir1 <- pop3.pheno
    }
    
    pop3.geno.em <- # genotype matrix after Mutation
          genotype(geno = pop3.geno,
                   blk.rg = blk.rg,
                   recom.spot = recom.spot,
                   range.hot = range.hot,
                   range.cold = range.cold,
                   # recom.cri = "cri3",
                   rate.mut = rate.mut, 
                   verbose = verbose)
    pop4.geno.em <- NULL
  }

  if (mtd.reprod == "doubcro") {
    logging.log("---base population4---\n", verbose = verbose)
    if (is.null(rawgeno4)) {
      prob1 <- runif(1)
      prob <- c(prob1, 1 - prob1)
      pop4.geno <- genotype(num.marker = num.marker, num.ind = num.ind, prob = prob, verbose = verbose)
    } else {
      pop4.geno <- genotype(rawgeno = rawgeno4, verbose = verbose)
    }

    # set base population information
    nind4 <- ncol(pop4.geno) / 2
    pop4 <- getpop(nind4, nind+nind2+nind3+1, 0)
    
    # calculate phenotype according to genotype
    if (sel.on) {
      pop4.pheno <-
        phenotype(effs = effs,
                  pop = pop4,
                  pop.geno = pop4.geno,
                  pos.map = pos.map,
                  h2.tr1 = h2.tr1,
                  gnt.cov = gnt.cov,
                  env.cov = env.cov,
                  sel.crit = sel.crit, 
                  pop.total = pop4, 
                  sel.on = sel.on, 
                  inner.env =  inner.env, 
                  verbose = verbose)
      pop4 <- set.pheno(pop4, pop4.pheno, sel.crit)
      trait$pop.dam2 <- pop4.pheno
    }
    
    pop4.geno.em <- # genotype matrix after Mutation
          genotype(geno = pop4.geno,
                   blk.rg = blk.rg,
                   recom.spot = recom.spot,
                   range.hot = range.hot,
                   range.cold = range.cold,
                   # recom.cri = "cri3",
                   rate.mut = rate.mut, 
                   verbose = verbose)
  }

  ################### SETTING_PROCESS ###################
  # 1. setting of number of progenies in every generation.
  # 2. setting of directory

  # adjust for genetic correlation
  ps <- ifelse(sel.on, ps, 1)
  # calculate number of individuals in every generation
	count.ind <- rep(nind, num.gen)
  if (mtd.reprod == "clone" || mtd.reprod == "dh" || mtd.reprod == "selfpol") {
    if (num.gen > 1) {
      for(i in 2:num.gen) {
        count.ind[i] <- round(count.ind[i-1] * (1-ratio) * ps) * num.prog
      }
    }
    
  } else if (mtd.reprod == "randmate" || mtd.reprod == "randexself") {
    if (num.gen > 1) {
      for(i in 2:num.gen) {
        count.ind[i] <- round(count.ind[i-1] * (1-ratio) * ps) * num.prog
      }
    }

  } else if (mtd.reprod == "singcro") {
    sing.ind <- round(nrow(pop2) * ps) * num.prog
    count.ind <- c(nrow(basepop), nrow(pop2), sing.ind)

  } else if (mtd.reprod == "tricro") {
    dam21.ind <- round(nrow(pop2) * ps) * prog.tri
    tri.ind <- round(dam21.ind * (1-ratio) * ps) * num.prog
    count.ind <- c(nrow(basepop), nrow(pop2), nrow(pop3), dam21.ind, tri.ind)

  } else if (mtd.reprod == "doubcro") {
    sir11.ind <- round(nrow(pop2) * ps) * prog.doub
    dam22.ind <- round(nrow(pop4) * ps) * prog.doub
    doub.ind <- round(dam22.ind * (1-ratio) * ps) * num.prog
    count.ind <- c(nrow(basepop), nrow(pop2), nrow(pop3), nrow(pop4), sir11.ind, dam22.ind, doub.ind)

  } else if (mtd.reprod == "backcro") {
    count.ind[1] <- nrow(basepop) + nrow(pop2)
    if (num.gen > 1) {
      count.ind[2] <- round(nrow(pop2) * ps) * num.prog
      for(i in 3:num.gen) {
        count.ind[i] <- round(count.ind[i-1] * (1-ratio) * ps) * num.prog
      }
    }
  }

  if (mtd.reprod != "userped") {
    # Create a folder to save files
    if (!is.null(out)) {
      if (!dir.exists(out)) stop("Please check your outpath!")
      if (out.format == "numeric") {
        out = paste0(out, .Platform$file.sep, sum(count.ind), "_Simer_Data_numeric")
      } else if (out.format == "plink"){
        out = paste0(out, .Platform$file.sep, sum(count.ind), "_Simer_Data_plink")
      } else {
        stop("out.format should be 'numeric' or 'plink'!")
      }
      if (!dir.exists(out)) dir.create(out)
      
      directory.rep <- paste0(out, .Platform$file.sep, "replication", replication)
      if (dir.exists(directory.rep)) {
        remove_bigmatrix(file.path(directory.rep, "genotype"))
        unlink(directory.rep, recursive = TRUE)
      }
      dir.create(directory.rep)
    }
  }

	# calculate selection intensity
	sel.i <- dnorm(qnorm(1 -ps)) / ps 
	logging.log("---selection intensity---\n", verbose = verbose)
	logging.log("Selection intensity is", sel.i, "\n", verbose = verbose)
	
  ################### REPRODUCTION_PROCESS ###################
  # 1. Reproduction based on basepop and basepop.geno according
  #    to different reproduction method.
  logging.log("---start reproduction---\n", verbose = verbose)
  # multi-generation: clone, dh, selpol, randmate, randexself
  if (mtd.reprod == "clone" || mtd.reprod == "dh" || mtd.reprod == "selfpol" || mtd.reprod == "randmate" || mtd.reprod == "randexself") {
    out.geno.index <- getindex(count.ind, out.geno.gen)
    out.pheno.index <- getindex(count.ind, out.pheno.gen)

    # store all genotype
    if (!sel.on) {
      geno.total.temp <- big.matrix(
        nrow = num.marker,
        ncol = 2*sum(count.ind),
        init = 3,
        type = 'char')
    } else {
      geno.total.temp <- NULL
    }
    
    if (!is.null(out)) {
      geno.total <- filebacked.big.matrix(
        nrow = num.marker,
        ncol = sum(count.ind[out.geno.gen]),
        init = 3,
        type = 'char',
        backingpath = directory.rep,
        backingfile = 'genotype.geno.bin',
        descriptorfile = 'genotype.geno.desc')
      options(bigmemory.typecast.warning=FALSE)
    } else {
      geno.total <- big.matrix(
        nrow = num.marker,
        ncol = sum(count.ind[out.geno.gen]),
        init = 3,
        type = 'char')
      options(bigmemory.typecast.warning=FALSE)
    }

    # set total population
    pop.total <- basepop
    
    if (1 %in% out.geno.gen) {
      gc <- geno.cvt(basepop.geno)
      input.geno(geno.total, gc, count.ind[1], mrk.dense)
    }
    if (!sel.on) {
      input.geno(geno.total.temp, basepop.geno, 2*count.ind[1], mrk.dense)
    }
    logging.log("After generation 1 ,", count.ind[1], "individuals are generated...\n", verbose = verbose)

    if (sel.on) {
      # add selection to generation1
      ind.ordered <-
        selects(pop = basepop,
                decr = decr,
                sel.multi = sel.multi,
                index.wt = index.wt,
                index.tdm = index.tdm,
                goal.perc = goal.perc,
                pass.perc = pass.perc,
                sel.sing = sel.sing,
                pop.total = basepop,
                pop.pheno = pop1.pheno, 
                verbose = verbose)
      index.tdm <- ind.ordered[1]
      ind.ordered <- ind.ordered[-1]
      ind.stay <- ind.ordered[1:(count.ind[2]/num.prog/(1-ratio))]
    } else {
      ind.stay <- basepop$index
    }
    
    if (num.gen > 2) {
      pop.last <- basepop
      pop.geno.last <- basepop.geno.em
      for (i in 2:num.gen) {
        pop.gp <- # pop.gp with genotype and pop information
          reproduces(pop1 = pop.last,
                     pop1.geno = pop.geno.last,
                     ind.stay = ind.stay,
                     mtd.reprod = mtd.reprod,
                     num.prog = num.prog,
                     ratio = ratio)
        
        pop.geno.curr <- pop.gp$geno
        pop.curr <- pop.gp$pop
        isd <- c(2, 5, 6)
        pop.total.temp <- rbind(pop.total[1:sum(count.ind[1:(i-1)]), isd], pop.curr[, isd])
        if (sel.on) {
          pop.pheno <-
            phenotype(effs = effs,
                      pop = pop.curr,
                      pop.geno = pop.geno.curr,
                      pos.map = pos.map,
                      h2.tr1 = h2.tr1,
                      gnt.cov = gnt.cov,
                      env.cov = env.cov,
                      sel.crit = sel.crit, 
                      pop.total = pop.total.temp, 
                      sel.on = sel.on, 
                      inner.env =  inner.env, 
                      verbose = verbose)
          pop.curr <- set.pheno(pop.curr, pop.pheno, sel.crit)
          trait[[i]]<- pop.pheno
        }
        
        pop.total <- rbind(pop.total, pop.curr)
        if (i %in% out.geno.gen) {
          gc <- geno.cvt(pop.geno.curr)
          out.gg <- out.geno.gen[1:which(out.geno.gen == i)]
          input.geno(geno.total, gc, sum(count.ind[out.gg]), mrk.dense)
        }
        if (!sel.on) {
          input.geno(geno.total.temp, pop.geno.curr, sum(count.ind[1:i]), mrk.dense)
        }
        logging.log("After generation", i, ",", sum(count.ind[1:i]), "individuals are generated...\n", verbose = verbose)
        
        if (i == num.gen) break
        
        if (sel.on) {
          # output index.tdm and ordered individuals indice
          ind.ordered <-
            selects(pop = pop.curr,
                    decr = decr,
                    sel.multi = sel.multi,
                    index.wt = index.wt,
                    index.tdm = index.tdm,
                    goal.perc = goal.perc,
                    pass.perc = pass.perc,
                    sel.sing = sel.sing,
                    pop.total = pop.total.temp,
                    pop.pheno = pop.pheno, 
                    verbose = verbose)
          index.tdm <- ind.ordered[1]
          ind.ordered <- ind.ordered[-1]
          ind.stay <- ind.ordered[1:(count.ind[i+1]/num.prog/(1-ratio))]
        } else {
          ind.stay <- pop.curr$index
        }
        
        pop.geno.last <-  # genotype matrix after Exchange and Mutation
          genotype(geno = pop.geno.curr,
                   blk.rg = blk.rg,
                   recom.spot = recom.spot,
                   range.hot = range.hot,
                   range.cold = range.cold,
                   # recom.cri = "cri3",
                   rate.mut = rate.mut, 
                   verbose = verbose)
        pop.last <- pop.curr
      }  # end for
    }
    
    # if traits have genetic correlation
    # generate phenotype at last
    if (!sel.on) {
      pop.pheno <-
        phenotype(effs = effs,
                  pop = pop.total,
                  pop.geno = geno.total.temp,
                  pos.map = pos.map,
                  h2.tr1 = h2.tr1,
                  gnt.cov = gnt.cov,
                  env.cov = env.cov,
                  sel.crit = sel.crit, 
                  pop.total = pop.total, 
                  sel.on = sel.on, 
                  inner.env =  inner.env, 
                  verbose = verbose)
      pop.total <- set.pheno(pop.total, pop.pheno, sel.crit)
      trait <- pop.pheno
    }
    
    if (!is.null(out)) {
      # write files
      logging.log("---write files of total population---\n", verbose = verbose)
      write.file(pop.total, geno.total, pos.map, out.geno.index, out.pheno.index, seed.map, directory.rep, out.format, verbose)
      flush(geno.total)
    }
    
    if (num.gen > 1) {
      rm(pop.gp); rm(pop.curr); rm(pop.geno.curr); rm(pop.last); 
      rm(pop.geno.last); rm(pop.total.temp); 
    }
    rm(basepop); rm(basepop.geno); rm(basepop.geno.em); rm(geno.total.temp); gc()
     
    # certain-generation: singcro, tricro, doubcro
  } else if (mtd.reprod == "singcro") {
    out.geno.index <- 1:sum(count.ind)
    logging.log("After generation", 1, ",", sum(count.ind[1:2]), "individuals are generated...\n", verbose = verbose)
    
    if (!is.null(out)) {
      dir.sir <- paste0(directory.rep, .Platform$file.sep, count.ind[1], "_sir")
      dir.dam <- paste0(directory.rep, .Platform$file.sep, count.ind[2], "_dam")
      dir.sgc <- paste0(directory.rep, .Platform$file.sep, count.ind[3], "_single_cross")
      if (dir.exists(dir.sir)) { unlink(dir.sir, recursive = TRUE) }
      if (dir.exists(dir.dam)) { unlink(dir.dam, recursive = TRUE) }
      if (dir.exists(dir.sgc)) { unlink(dir.sgc, recursive = TRUE) }
      dir.create(dir.sir)
      dir.create(dir.dam)
      dir.create(dir.sgc)

      geno.sir <- filebacked.big.matrix(
        nrow = num.marker,
        ncol = count.ind[1],
        init = 3,
        type = 'char',
        backingpath = dir.sir,
        backingfile = 'genotype.geno.bin',
        descriptorfile = 'genotype.geno.desc')
      geno.dam <- filebacked.big.matrix(
        nrow = num.marker,
        ncol = count.ind[2],
        init = 3,
        type = 'char',
        backingpath = dir.dam,
        backingfile = 'genotype.geno.bin',
        descriptorfile = 'genotype.geno.desc')
      geno.singcro <- filebacked.big.matrix(
        nrow = num.marker,
        ncol = count.ind[3],
        init = 3,
        type = 'char',
        backingpath = dir.sgc,
        backingfile = 'genotype.geno.bin',
        descriptorfile = 'genotype.geno.desc')
      options(bigmemory.typecast.warning=FALSE)
    } else {
      geno.sir <- big.matrix(
        nrow = num.marker,
        ncol = count.ind[1],
        init = 3,
        type = 'char')
      geno.dam <- big.matrix(
        nrow = num.marker,
        ncol = count.ind[2],
        init = 3,
        type = 'char')
      geno.singcro <- big.matrix(
        nrow = num.marker,
        ncol = count.ind[3],
        init = 3,
        type = 'char')
      options(bigmemory.typecast.warning=FALSE)
    }
    
    if (sel.on) {
      # output index.tdm and ordered individuals indice
      ind.ordered <-
        selects(pop = basepop,
                decr = decr,
                sel.multi = sel.multi,
                index.wt = index.wt,
                index.tdm = index.tdm,
                goal.perc = goal.perc,
                pass.perc = pass.perc,
                sel.sing = sel.sing,
                pop.total = basepop,
                pop.pheno = pop1.pheno, 
                verbose = verbose)
      index.tdm <- ind.ordered[1]
      ind.ordered <- ind.ordered[-1]
      ind.stay1 <- ind.ordered[1:(count.ind[2]/num.prog)]
      ind.ordered <-
        selects(pop = pop2,
                decr = decr,
                sel.multi = sel.multi,
                index.wt = index.wt,
                index.tdm = index.tdm,
                goal.perc = goal.perc,
                pass.perc = pass.perc,
                sel.sing = sel.sing,
                pop.total = pop2,
                pop.pheno = pop2.pheno, 
                verbose = verbose)
      index.tdm <- ind.ordered[1]
      ind.ordered <- ind.ordered[-1]
      ind.stay2 <- ind.ordered[1:(count.ind[2]/num.prog)]
      ind.stay <- c(ind.stay1, ind.stay2)
    } else {
      ind.stay <- c(basepop$index, pop2$index)
    }
    
    pop.gp <-
        reproduces(pop1 = basepop,
                   pop2 = pop2,
                   pop1.geno = basepop.geno.em,
                   pop2.geno = pop2.geno.em,
                   ind.stay = ind.stay,
                   mtd.reprod = mtd.reprod,
                   num.prog = num.prog,
                   ratio = ratio)

    pop.geno.singcro <- pop.gp$geno
    pop.singcro <- pop.gp$pop
    isd <- c(2, 5, 6)
    pop.total.temp <- rbind(basepop[, isd], pop2[, isd], pop.singcro[, isd])
    
    if (sel.on) {
      pop.pheno <-
        phenotype(effs = effs,
                  pop = pop.singcro,
                  pop.geno = pop.geno.singcro,
                  pos.map = pos.map,
                  h2.tr1 = h2.tr1,
                  gnt.cov = gnt.cov,
                  env.cov = env.cov,
                  sel.crit = sel.crit, 
                  pop.total = pop.total.temp, 
                  sel.on = sel.on, 
                  inner.env =  inner.env, 
                  verbose = verbose)
      pop.singcro <- set.pheno(pop.singcro, pop.pheno, sel.crit)
      trait$pop.singcro <- pop.pheno
    }
    
    logging.log("After generation", 2, ",", sum(count.ind[1:3]), "individuals are generated...\n", verbose = verbose)

    gc.sir <- geno.cvt(basepop.geno)
    gc.dam <- geno.cvt(pop2.geno)
    gc.singcro <- geno.cvt(pop.geno.singcro)
    input.geno(geno.sir, gc.sir, ncol(geno.sir), mrk.dense)
    input.geno(geno.dam, gc.dam, ncol(geno.dam), mrk.dense)
    input.geno(geno.singcro, gc.singcro, ncol(geno.singcro), mrk.dense)
    
    # if traits have genetic correlation
    # generate phenotype at last
    if (!sel.on) {
      pop.total <- rbind(basepop, pop2, pop.singcro)
      geno.total <- cbind(basepop.geno, pop2.geno, pop.geno.singcro)
      pop.pheno <-
        phenotype(effs = effs,
                  pop = pop.total,
                  pop.geno = geno.total,
                  pos.map = pos.map,
                  h2.tr1 = h2.tr1,
                  gnt.cov = gnt.cov,
                  env.cov = env.cov,
                  sel.crit = sel.crit, 
                  pop.total = pop.total, 
                  sel.on = sel.on, 
                  inner.env =  inner.env, 
                  verbose = verbose)
      pop.total <- set.pheno(pop.total, pop.pheno, sel.crit)
      trait <- pop.pheno
      basepop$pheno <- pop.total$pheno[1:nind, ]
      pop2$pheno <- pop.total$pheno[(nind+1):(nind+nind2)]
      pop.singcro$pheno <- pop.total$pheno[(nind+nind2+1):(nind+nind2+nrow(pop.singcro))]
    }
    
    if (!is.null(out)) {
      flush(geno.sir)
      flush(geno.dam)
      flush(geno.singcro)
      # write files
      logging.log("---write files of sirs---\n", verbose = verbose)
      write.file(basepop, geno.sir, pos.map, 1:nrow(basepop), 1:nrow(basepop), seed.map, dir.sir, out.format, verbose)
      logging.log("---write files of dams---\n", verbose = verbose)
      write.file(pop2, geno.dam, pos.map, 1:nrow(pop2), 1:nrow(pop2), seed.map, dir.dam, out.format, verbose)
      logging.log("---write files of progenies---\n", verbose = verbose)
      write.file(pop.singcro, geno.singcro, pos.map, 1:nrow(pop.singcro), 1:nrow(pop.singcro), seed.map, dir.sgc, out.format, verbose)
    }
    
    # set total information of population and genotype
    pop.total <- list(pop.sir1 = basepop, pop.dam1 = pop2, pop.singcro = pop.singcro)
    geno.total <- list(geno.sir1 = gc.sir, geno.dam1 = gc.dam, geno.singcro = gc.singcro)
    
    rm(basepop); rm(basepop.geno); rm(basepop.geno.em); rm(pop2); rm(pop2.geno); rm(pop2.geno.em);
    rm(geno.sir); rm(geno.dam); rm(geno.singcro); rm(pop.gp); rm(pop.singcro); rm(pop.geno.singcro); 
    rm(gc.sir); rm(gc.dam); rm(gc.singcro); rm(pop.total.temp); gc()
    
  } else if (mtd.reprod == "tricro") {
    out.geno.index <- 1:sum(count.ind)
    logging.log("After generation", 1, ",", sum(count.ind[1:3]), "individuals are generated...\n", verbose = verbose)
    
    if (!is.null(out)) {
      dir.sir1  <- paste0(directory.rep, .Platform$file.sep, count.ind[1], "_sir1")
      dir.dam1  <- paste0(directory.rep, .Platform$file.sep, count.ind[2], "_dam1")
      dir.sir2  <- paste0(directory.rep, .Platform$file.sep, count.ind[3], "_sir2")
      dir.dam21 <- paste0(directory.rep, .Platform$file.sep, count.ind[4], "_dam21")
      dir.trc   <- paste0(directory.rep, .Platform$file.sep, count.ind[5], "_three-ways_cross")
      if (dir.exists(dir.sir1))  { unlink(dir.sir1, recursive = TRUE) }
      if (dir.exists(dir.dam1))  { unlink(dir.dam1, recursive = TRUE) }
      if (dir.exists(dir.sir2))  { unlink(dir.sir2, recursive = TRUE) }
      if (dir.exists(dir.dam21)) { unlink(dir.dam21, recursive = TRUE) }
      if (dir.exists(dir.trc))   { unlink(dir.trc, recursive = TRUE) }
      dir.create(dir.sir1)
      dir.create(dir.dam1)
      dir.create(dir.sir2)
      dir.create(dir.dam21)
      dir.create(dir.trc)
    
      geno.sir1 <- filebacked.big.matrix(
        nrow = num.marker,
        ncol = count.ind[1],
        init = 3,
        type = 'char',
        backingpath = dir.sir1,
        backingfile = 'genotype.geno.bin',
        descriptorfile = 'genotype.geno.desc')
      geno.dam1 <- filebacked.big.matrix(
        nrow = num.marker,
        ncol = count.ind[2],
        init = 3,
        type = 'char',
        backingpath = dir.dam1,
        backingfile = 'genotype.geno.bin',
        descriptorfile = 'genotype.geno.desc')
      geno.sir2 <- filebacked.big.matrix(
        nrow = num.marker,
        ncol = count.ind[3],
        init = 3,
        type = 'char',
        backingpath = dir.sir2,
        backingfile = 'genotype.geno.bin',
        descriptorfile = 'genotype.geno.desc')
      geno.dam21 <- filebacked.big.matrix(
        nrow = num.marker,
        ncol = count.ind[4],
        init = 3,
        type = 'char',
        backingpath = dir.dam21,
        backingfile = 'genotype.geno.bin',
        descriptorfile = 'genotype.geno.desc')
      geno.tricro <- filebacked.big.matrix(
        nrow = num.marker,
        ncol = count.ind[5],
        init = 3,
        type = 'char',
        backingpath = dir.trc,
        backingfile = 'genotype.geno.bin',
        descriptorfile = 'genotype.geno.desc')
      options(bigmemory.typecast.warning=FALSE)
    } else {
      geno.sir1 <- big.matrix(
        nrow = num.marker,
        ncol = count.ind[1],
        init = 3,
        type = 'char')
      geno.dam1 <- big.matrix(
        nrow = num.marker,
        ncol = count.ind[2],
        init = 3,
        type = 'char')
      geno.sir2 <- big.matrix(
        nrow = num.marker,
        ncol = count.ind[3],
        init = 3,
        type = 'char')
      geno.dam21 <- big.matrix(
        nrow = num.marker,
        ncol = count.ind[4],
        init = 3,
        type = 'char')
      geno.tricro <- big.matrix(
        nrow = num.marker,
        ncol = count.ind[5],
        init = 3,
        type = 'char')
      options(bigmemory.typecast.warning=FALSE)
    }
    
    # correct the sex
    pop2$sex <- 1
    pop3$sex <- 2
    
    if (sel.on) {
      # add selection to generation1
      ind.ordered <-
        selects(pop = pop2,
                decr = decr,
                sel.multi = sel.multi,
                index.wt = index.wt,
                index.tdm = index.tdm,
                goal.perc = goal.perc,
                pass.perc = pass.perc,
                sel.sing = sel.sing,
                pop.total = pop2,
                pop.pheno = pop2.pheno, 
                verbose = verbose)
      index.tdm <- ind.ordered[1]
      ind.ordered <- ind.ordered[-1]
      ind.stay1 <- ind.ordered[1:(count.ind[2]/num.prog)]
      ind.ordered <-
        selects(pop = pop3,
                decr = decr,
                sel.multi = sel.multi,
                index.wt = index.wt,
                index.tdm = index.tdm,
                goal.perc = goal.perc,
                pass.perc = pass.perc,
                sel.sing = sel.sing,
                pop.total = pop3,
                pop.pheno = pop3.pheno, 
                verbose = verbose)
      index.tdm <- ind.ordered[1]
      ind.ordered <- ind.ordered[-1]
      ind.stay2 <- ind.ordered[1:(count.ind[2]/num.prog)]
      ind.stay <- c(ind.stay1, ind.stay2)
    } else {
      ind.stay <- c(pop2$index, pop3$index)
    }
    
    # the first generation to the second generation
    pop.gp <-
        reproduces(pop1 = pop2,
                   pop2 = pop3,
                   pop1.geno = pop2.geno.em,
                   pop2.geno = pop3.geno.em,
                   ind.stay = ind.stay,
                   mtd.reprod = "singcro",
                   num.prog = num.prog,
                   ratio = ratio)

    pop.geno.dam21 <- pop.gp$geno
    pop.dam21 <- pop.gp$pop
    isd <- c(2, 5, 6)
    pop.total.temp <- rbind(basepop[, isd], pop2[, isd], pop3[, isd], pop.dam21[, isd])
    
    if (sel.on) {
      pop.pheno <-
        phenotype(effs = effs,
                  pop = pop.dam21,
                  pop.geno = pop.geno.dam21,
                  pos.map = pos.map,
                  h2.tr1 = h2.tr1,
                  gnt.cov = gnt.cov,
                  env.cov = env.cov,
                  sel.crit = sel.crit, 
                  pop.total = pop.total.temp, 
                  sel.on = sel.on, 
                  inner.env =  inner.env, 
                  verbose = verbose)
      pop.dam21 <- set.pheno(pop.dam21, pop.pheno, sel.crit)
      trait$pop.dam21 <- pop.pheno
      
      # output index.tdm and ordered individuals indice
      ind.ordered <-
        selects(pop = pop.dam21,
                decr = decr,
                sel.multi = sel.multi,
                index.wt = index.wt,
                index.tdm = index.tdm,
                goal.perc = goal.perc,
                pass.perc = pass.perc,
                sel.sing = sel.sing,
                pop.total = pop.total.temp,
                pop.pheno = pop.pheno, 
                verbose = verbose)
      index.tdm <- ind.ordered[1]
      ind.ordered <- ind.ordered[-1]
      ind.stay <- c(basepop$index, ind.ordered[1:(count.ind[5]/(num.prog*(sum(pop.dam21$sex==2)/nrow(pop.dam21))))])
    } else {
      ind.stay <- c(basepop$index, pop.dam21$index)
    }
    
    logging.log("After generation", 2, ",", sum(count.ind[1:4]), "individuals are generated...\n", verbose = verbose)
    
    pop.geno.dam21.em <-  # genotype matrix after Exchange and Mutation
        genotype(geno = pop.geno.dam21,
                 blk.rg = blk.rg,
                 recom.spot = recom.spot,
                 range.hot = range.hot,
                 range.cold = range.cold,
                 # recom.cri = "cri3",
                 rate.mut = rate.mut, 
                 verbose = verbose)

    # the second generation to the third generation
    pop.gp <-
        reproduces(pop1 = basepop,
                   pop2 = pop.dam21,
                   pop1.geno = basepop.geno.em,
                   pop2.geno = pop.geno.dam21.em,
                   ind.stay = ind.stay,
                   mtd.reprod = "singcro",
                   num.prog = num.prog,
                   ratio = ratio)

    pop.geno.tricro <- pop.gp$geno
    pop.tricro <- pop.gp$pop
    isd <- c(2, 5, 6)
    pop.total.temp <- rbind(pop.total.temp, pop.tricro[, isd])
    
    if (sel.on) {
      pop.pheno <-
        phenotype(effs = effs,
                  pop = pop.tricro,
                  pop.geno = pop.geno.tricro,
                  pos.map = pos.map,
                  h2.tr1 = h2.tr1,
                  gnt.cov = gnt.cov,
                  env.cov = env.cov,
                  sel.crit = sel.crit, 
                  pop.total = pop.total.temp, 
                  sel.on = sel.on, 
                  inner.env =  inner.env, 
                  verbose = verbose)
      pop.tricro <- set.pheno(pop.tricro, pop.pheno, sel.crit)
      trait$pop.tricro <- pop.pheno
    }
    
    logging.log("After generation", 3, ",", sum(count.ind[1:5]), "individuals are generated...\n", verbose = verbose)

    gc.sir1 <- geno.cvt(basepop.geno)
    gc.sir2 <- geno.cvt(pop2.geno)
    gc.dam1 <- geno.cvt(pop3.geno)
    gc.dam21 <- geno.cvt(pop.geno.dam21)
    gc.tricro <- geno.cvt(pop.geno.tricro)
    input.geno(geno.sir1, gc.sir1, ncol(geno.sir1), mrk.dense)
    input.geno(geno.sir2, gc.sir2, ncol(geno.dam1), mrk.dense)
    input.geno(geno.dam1, gc.dam1, ncol(geno.sir2), mrk.dense)
    input.geno(geno.dam21, gc.dam21, ncol(geno.dam21), mrk.dense)
    input.geno(geno.tricro, gc.tricro, ncol(geno.tricro), mrk.dense)
    
    # if traits have genetic correlation
    # generate phenotype at last
    if (!sel.on) {
      pop.total <- rbind(basepop, pop2, pop3, pop.dam21, pop.tricro)
      geno.total <- cbind(basepop.geno, pop2.geno, pop3.geno, pop.geno.dam21[], pop.geno.tricro[])
      pop.pheno <-
        phenotype(effs = effs,
                  pop = pop.total,
                  pop.geno = geno.total,
                  pos.map = pos.map,
                  h2.tr1 = h2.tr1,
                  gnt.cov = gnt.cov,
                  env.cov = env.cov,
                  sel.crit = sel.crit, 
                  pop.total = pop.total, 
                  sel.on = sel.on, 
                  inner.env =  inner.env, 
                  verbose = verbose)
      pop.total <- set.pheno(pop.total, pop.pheno, sel.crit)
      trait <- pop.pheno
      basepop$pheno <- pop.total$pheno[1:nind, ]
      pop2$pheno <- pop.total$pheno[(nind+1):(nind+nind2)]
      pop3$pheno <- pop.total$pheno[(nind+nind2+1):(nind+nind2+nind3)]
      pop.dam21$pheno <- pop.total$pheno[(nind+nind2+nind3+1):(nind+nind2+nind3+nrow(pop.dam21))]
      pop.tricro$pheno <- pop.total$pheno[(nind+nind2+nind3+nrow(pop.dam21)+1):(nind+nind2+nind3+nrow(pop.dam21)+nrow(pop.tricro))]
    }
    
    if (!is.null(out)) {
      flush(geno.sir1)
      flush(geno.dam1)
      flush(geno.sir2)
      flush(geno.dam21)
      flush(geno.tricro)
      # write files
      logging.log("---write files of sir1s---\n", verbose = verbose)
      write.file(basepop, geno.sir1, pos.map, 1:nrow(basepop), 1:nrow(basepop), seed.map, dir.sir1, out.format, verbose)
      logging.log("---write files of sir2s---\n", verbose = verbose)
      write.file(pop2, geno.sir2, pos.map, 1:nrow(pop2), 1:nrow(pop2), seed.map, dir.sir2, out.format, verbose)
      logging.log("---write files of dam1s---\n", verbose = verbose)
      write.file(pop3, geno.dam1, pos.map, 1:nrow(pop3), 1:nrow(pop3), seed.map, dir.dam1, out.format, verbose)
      logging.log("---write files of dam21s---\n", verbose = verbose)
      write.file(pop.dam21, geno.dam21, pos.map, 1:nrow(pop.dam21), 1:nrow(pop.dam21), seed.map, dir.dam21, out.format, verbose)
      logging.log("---write files of progenies---\n", verbose = verbose)
      write.file(pop.tricro, geno.tricro, pos.map, 1:nrow(pop.tricro), 1:nrow(pop.tricro), seed.map, dir.trc, out.format, verbose)
    }
    
    # set total information of population and genotype
    pop.total <- list(pop.sir1 = basepop, pop.sir2 = pop2, pop.dam1 = pop3, pop.dam21 = pop.dam21, pop.tricro = pop.tricro)
    geno.total <- list(geno.sir1 = gc.sir1, geno.sir2 = gc.sir2, geno.dam1 = gc.dam1, geno.dam21 = gc.dam21, geno.tricro = gc.tricro)
    
    rm(basepop); rm(basepop.geno); rm(basepop.geno.em); rm(pop2); rm(pop2.geno); rm(pop2.geno.em);
    rm(pop3); rm(pop3.geno); rm(pop3.geno.em); rm(geno.sir1); rm(geno.dam1); rm(geno.sir2);
    rm(pop.gp); rm(pop.dam21); rm(geno.dam21); rm(pop.geno.dam21); rm(pop.geno.dam21.em);
    rm(gc.sir1); rm(gc.sir2); rm(gc.dam1); rm(gc.dam21); rm(gc.tricro);
    rm(pop.tricro); rm(geno.tricro); rm(pop.total.temp); gc()

  } else if (mtd.reprod == "doubcro") {
    out.geno.index <- 1:sum(count.ind)
    logging.log("After generation", 1, ",", sum(count.ind[1:4]), "individuals are generated...\n", verbose = verbose)
    
    if (!is.null(out)) {
      dir.sir1  <- paste0(directory.rep, .Platform$file.sep, count.ind[1], "_sir1")
      dir.dam1  <- paste0(directory.rep, .Platform$file.sep, count.ind[2], "_dam1")
      dir.sir2  <- paste0(directory.rep, .Platform$file.sep, count.ind[3], "_sir2")
      dir.dam2  <- paste0(directory.rep, .Platform$file.sep, count.ind[4], "_dam2")
      dir.sir11 <- paste0(directory.rep, .Platform$file.sep, count.ind[5], "_sir11")
      dir.dam22 <- paste0(directory.rep, .Platform$file.sep, count.ind[6], "_dam22")
      dir.dbc   <- paste0(directory.rep, .Platform$file.sep, count.ind[7], "_double_cross")
      if (dir.exists(dir.sir1))  { unlink(dir.sir1, recursive = TRUE) }
      if (dir.exists(dir.dam1))  { unlink(dir.dam1, recursive = TRUE) }
      if (dir.exists(dir.sir2))  { unlink(dir.sir2, recursive = TRUE) }
      if (dir.exists(dir.dam2))  { unlink(dir.dam2, recursive = TRUE) }
      if (dir.exists(dir.sir11)) { unlink(dir.sir11, recursive = TRUE) }
      if (dir.exists(dir.dam22)) { unlink(dir.dam22, recursive = TRUE) }
      if (dir.exists(dir.dbc))   { unlink(dir.dbc, recursive = TRUE) }
      dir.create(dir.sir1)
      dir.create(dir.dam1)
      dir.create(dir.sir2)
      dir.create(dir.dam2)
      dir.create(dir.sir11)
      dir.create(dir.dam22)
      dir.create(dir.dbc)
    
      geno.sir1 <- filebacked.big.matrix(
        nrow = num.marker,
        ncol = count.ind[1],
        init = 3,
        type = 'char',
        backingpath = dir.sir1,
        backingfile = 'genotype.geno.bin',
        descriptorfile = 'genotype.geno.desc')
      geno.dam1 <- filebacked.big.matrix(
        nrow = num.marker,
        ncol = count.ind[2],
        init = 3,
        type = 'char',
        backingpath = dir.dam1,
        backingfile = 'genotype.geno.bin',
        descriptorfile = 'genotype.geno.desc')
      geno.sir2 <- filebacked.big.matrix(
        nrow = num.marker,
        ncol = count.ind[3],
        init = 3,
        type = 'char',
        backingpath = dir.sir2,
        backingfile = 'genotype.geno.bin',
        descriptorfile = 'genotype.geno.desc')
      geno.dam2 <- filebacked.big.matrix(
        nrow = num.marker,
        ncol = count.ind[4],
        init = 3,
        type = 'char',
        backingpath = dir.dam2,
        backingfile = 'genotype.geno.bin',
        descriptorfile = 'genotype.geno.desc')
      geno.sir11 <- filebacked.big.matrix(
        nrow = num.marker,
        ncol = count.ind[5],
        init = 3,
        type = 'char',
        backingpath = dir.sir11,
        backingfile = 'genotype.geno.bin',
        descriptorfile = 'genotype.geno.desc')
      geno.dam22 <- filebacked.big.matrix(
        nrow = num.marker,
        ncol = count.ind[6],
        init = 3,
        type = 'char',
        backingpath = dir.dam22,
        backingfile = 'genotype.geno.bin',
        descriptorfile = 'genotype.geno.desc')
      geno.doubcro <- filebacked.big.matrix(
        nrow = num.marker,
        ncol = count.ind[7],
        init = 3,
        type = 'char',
        backingpath = dir.dbc,
        backingfile = 'genotype.geno.bin',
        descriptorfile = 'genotype.geno.desc')
      options(bigmemory.typecast.warning=FALSE)
    } else {
      geno.sir1 <- big.matrix(
        nrow = num.marker,
        ncol = count.ind[1],
        init = 3,
        type = 'char')
      geno.dam1 <- big.matrix(
        nrow = num.marker,
        ncol = count.ind[2],
        init = 3,
        type = 'char')
      geno.sir2 <- big.matrix(
        nrow = num.marker,
        ncol = count.ind[3],
        init = 3,
        type = 'char')
      geno.dam2 <- big.matrix(
        nrow = num.marker,
        ncol = count.ind[4],
        init = 3,
        type = 'char')
      geno.sir11 <- big.matrix(
        nrow = num.marker,
        ncol = count.ind[5],
        init = 3,
        type = 'char')
      geno.dam22 <- big.matrix(
        nrow = num.marker,
        ncol = count.ind[6],
        init = 3,
        type = 'char')
      geno.doubcro <- big.matrix(
        nrow = num.marker,
        ncol = count.ind[7],
        init = 3,
        type = 'char')
      options(bigmemory.typecast.warning=FALSE)
    }

    if (sel.on) {
      # add selection to generation1
      ind.ordered <-
        selects(pop = basepop,
                decr = decr,
                sel.multi = sel.multi,
                index.wt = index.wt,
                index.tdm = index.tdm,
                goal.perc = goal.perc,
                pass.perc = pass.perc,
                sel.sing = sel.sing,
                pop.total = basepop,
                pop.pheno = pop1.pheno, 
                verbose = verbose)
      index.tdm <- ind.ordered[1]
      ind.ordered <- ind.ordered[-1]
      ind.stay1 <- ind.ordered[1:(count.ind[2]/num.prog)]
      ind.ordered <-
        selects(pop = pop2,
                decr = decr,
                sel.multi = sel.multi,
                index.wt = index.wt,
                index.tdm = index.tdm,
                goal.perc = goal.perc,
                pass.perc = pass.perc,
                sel.sing = sel.sing,
                pop.total = pop2,
                pop.pheno = pop2.pheno, 
                verbose = verbose)
      index.tdm <- ind.ordered[1]
      ind.ordered <- ind.ordered[-1]
      ind.stay2 <- ind.ordered[1:(count.ind[2]/num.prog)]
      ind.stay <- c(ind.stay1, ind.stay2)
    } else {
      ind.stay <- c(basepop$index, pop2$index)
    }
    
    # the first generation to the second generation(the first two populations)
    pop.gp <-
        reproduces(pop1 = basepop,
                   pop2 = pop2,
                   pop1.geno = basepop.geno.em,
                   pop2.geno = pop2.geno.em,
                   ind.stay = ind.stay,
                   mtd.reprod = "singcro",
                   num.prog = num.prog,
                   ratio = ratio)

    pop.geno.sir11 <- pop.gp$geno
    pop.sir11 <- pop.gp$pop
    pop.sir11$index <- pop.sir11$index - pop.sir11$index[1] + 1 + pop4$index[length(pop4$index)]
    isd <- c(2, 5, 6)
    pop.total.temp <- rbind(basepop[, isd], pop2[, isd], pop3[, isd], pop4[, isd], pop.sir11[, isd])
    
    if (sel.on) {
      pop.pheno <-
        phenotype(effs = effs,
                  pop = pop.sir11,
                  pop.geno = pop.geno.sir11,
                  pos.map = pos.map,
                  h2.tr1 = h2.tr1,
                  gnt.cov = gnt.cov,
                  env.cov = env.cov,
                  sel.crit = sel.crit, 
                  pop.total = pop.total.temp, 
                  sel.on = sel.on, 
                  inner.env =  inner.env, 
                  verbose = verbose)
      pop.sir11 <- set.pheno(pop.sir11, pop.pheno, sel.crit)
      trait$pop.sir11 <- pop.pheno
      
      # output index.tdm and ordered individuals indice
      ind.ordered <-
        selects(pop = pop.sir11,
                decr = decr,
                sel.multi = sel.multi,
                index.wt = index.wt,
                index.tdm = index.tdm,
                goal.perc = goal.perc,
                pass.perc = pass.perc,
                sel.sing = sel.sing,
                pop.total = pop.total.temp,
                pop.pheno = pop.pheno, 
                verbose = verbose)
      index.tdm <- ind.ordered[1]
      ind.ordered <- ind.ordered[-1]
      ind.stay.sir11 <- ind.ordered[1:(count.ind[7]/(num.prog*(sum(pop.sir11$sex==2)/nrow(pop.sir11))))]
    } else {
      ind.stay.sir11 <- pop.sir11$index
    }
    
    pop.geno.sir11.em <-  # genotype matrix after Exchange and Mutation
        genotype(geno = pop.geno.sir11,
                 blk.rg = blk.rg,
                 recom.spot = recom.spot,
                 range.hot = range.hot,
                 range.cold = range.cold,
                 # recom.cri = "cri3",
                 rate.mut = rate.mut, 
                 verbose = verbose)

    if (sel.on) {
      # add selection to generation1
      ind.ordered <-
        selects(pop = pop3,
                decr = decr,
                sel.multi = sel.multi,
                index.wt = index.wt,
                index.tdm = index.tdm,
                goal.perc = goal.perc,
                pass.perc = pass.perc,
                sel.sing = sel.sing,
                pop.total = pop3,
                pop.pheno = pop3.pheno, 
                verbose = verbose)
      index.tdm <- ind.ordered[1]
      ind.ordered <- ind.ordered[-1]
      ind.stay1 <- ind.ordered[1:(count.ind[2]/num.prog)]
      ind.ordered <-
        selects(pop = pop4,
                decr = decr,
                sel.multi = sel.multi,
                index.wt = index.wt,
                index.tdm = index.tdm,
                goal.perc = goal.perc,
                pass.perc = pass.perc,
                sel.sing = sel.sing,
                pop.total = pop4,
                pop.pheno = pop4.pheno, 
                verbose = verbose)
      index.tdm <- ind.ordered[1]
      ind.ordered <- ind.ordered[-1]
      ind.stay2 <- ind.ordered[1:(count.ind[2]/num.prog)]
      ind.stay <- c(ind.stay1, ind.stay2)
    } else {
      ind.stay <- c(pop3$index, pop4$index)
    }
    
    # the first generation to the second generation(the last two populations)
    pop.gp <-
        reproduces(pop1 = pop3,
                   pop2 = pop4,
                   pop1.geno = pop3.geno.em,
                   pop2.geno = pop4.geno.em,
                   ind.stay = ind.stay,
                   mtd.reprod = "singcro",
                   num.prog = num.prog,
                   ratio = ratio)

    pop.geno.dam22 <- pop.gp$geno
    pop.dam22 <- pop.gp$pop
    pop.dam22$index <- pop.dam22$index - pop.dam22$index[1] + 1 + pop.sir11$index[length(pop.sir11$index)]
    pop.total.temp <- rbind(pop.total.temp, pop.dam22[, isd])
    
    if (sel.on) {
      pop.pheno <-
        phenotype(effs = effs,
                  pop = pop.dam22,
                  pop.geno = pop.geno.dam22,
                  pos.map = pos.map,
                  h2.tr1 = h2.tr1,
                  gnt.cov = gnt.cov,
                  env.cov = env.cov,
                  sel.crit = sel.crit, 
                  pop.total = pop.total.temp, 
                  sel.on = sel.on, 
                  inner.env =  inner.env, 
                  verbose = verbose)
      pop.dam22 <- set.pheno(pop.dam22, pop.pheno, sel.crit)
      trait$pop.dam22 <- pop.pheno
    }

    # output index.tdm and ordered individuals indice
    ind.ordered <-
        selects(pop = pop.dam22,
                decr = decr,
                sel.multi = sel.multi,
                index.wt = index.wt,
                index.tdm = index.tdm,
                goal.perc = goal.perc,
                pass.perc = pass.perc,
                sel.sing = sel.sing,
                pop.total = pop.total.temp,
                pop.pheno = pop.pheno, 
                verbose = verbose)
    # index.tdm <- ind.ordered[1]
    ind.ordered <- ind.ordered[-1]

    ind.stay.dam22 <- ind.ordered[1:(count.ind[7]/(num.prog*(sum(pop.dam22$sex==2)/nrow(pop.dam22))))]
    pop.geno.dam22.em <-  # genotype matrix after Exchange and Mutation
        genotype(geno = pop.geno.dam22,
                 blk.rg = blk.rg,
                 recom.spot = recom.spot,
                 range.hot = range.hot,
                 range.cold = range.cold,
                 # recom.cri = "cri3",
                 rate.mut = rate.mut, 
                 verbose = verbose)

    ind.stay <- c(ind.stay.sir11, ind.stay.dam22)
    
    logging.log("After generation", 2, ",", sum(count.ind[1:6]), "individuals are generated...\n", verbose = verbose)
    
    # the second generation to the third generation
    pop.gp <-
        reproduces(pop1 = pop.sir11,
                   pop2 = pop.dam22,
                   pop1.geno = pop.geno.sir11.em,
                   pop2.geno = pop.geno.dam22.em,
                   ind.stay = ind.stay,
                   mtd.reprod = "singcro",
                   num.prog = num.prog,
                   ratio = ratio)

    pop.geno.doubcro <- pop.gp$geno
    pop.doubcro <- pop.gp$pop
    pop.total.temp <- rbind(pop.total.temp, pop.doubcro[, isd])
    
    if (sel.on) {
      pop.pheno <-
        phenotype(effs = effs,
                  pop = pop.doubcro,
                  pop.geno = pop.geno.doubcro,
                  pos.map = pos.map,
                  h2.tr1 = h2.tr1,
                  gnt.cov = gnt.cov,
                  env.cov = env.cov,
                  sel.crit = sel.crit, 
                  pop.total = pop.total.temp, 
                  sel.on = sel.on, 
                  inner.env =  inner.env, 
                  verbose = verbose)
      pop.doubcro <- set.pheno(pop.doubcro, pop.pheno, sel.crit)
      trait$pop.doubcro <- pop.pheno
    }
    
    logging.log("After generation", 3, ",", sum(count.ind[1:7]), "individuals are generated...\n", verbose = verbose)

    gc.sir1 <- geno.cvt(basepop.geno)
    gc.dam1 <- geno.cvt(pop2.geno)
    gc.sir2 <- geno.cvt(pop3.geno)
    gc.dam2 <- geno.cvt(pop4.geno)
    gc.sir11 <- geno.cvt(pop.geno.sir11)
    gc.dam22 <- geno.cvt(pop.geno.dam22)
    gc.doubcro <- geno.cvt(pop.geno.doubcro)
    input.geno(geno.sir1, gc.sir1, ncol(geno.sir1), mrk.dense)
    input.geno(geno.dam1, gc.dam1, ncol(geno.dam1), mrk.dense)
    input.geno(geno.sir2, gc.sir2, ncol(geno.sir2), mrk.dense)
    input.geno(geno.dam2, gc.dam2, ncol(geno.dam2), mrk.dense)
    input.geno(geno.sir11, gc.sir11, ncol(geno.sir11), mrk.dense)
    input.geno(geno.dam22, gc.dam22, ncol(geno.dam22), mrk.dense)
    input.geno(geno.doubcro, gc.doubcro, ncol(geno.doubcro), mrk.dense)
    
    # if traits have genetic correlation
    # generate phenotype at last
    if (!sel.on) {
      pop.total <- rbind(basepop, pop2, pop3, pop4, pop.sir11, pop.dam22, pop.doubcro)
      geno.total <- cbind(basepop.geno, pop2.geno, pop3.geno, pop4.geno, pop.geno.sir11[], pop.geno.dam22[], pop.geno.doubcro[])
      pop.pheno <-
        phenotype(effs = effs,
                  pop = pop.total,
                  pop.geno = geno.total,
                  pos.map = pos.map,
                  h2.tr1 = h2.tr1,
                  gnt.cov = gnt.cov,
                  env.cov = env.cov,
                  sel.crit = sel.crit, 
                  pop.total = pop.total, 
                  sel.on = sel.on, 
                  inner.env =  inner.env, 
                  verbose = verbose)
      pop.total <- set.pheno(pop.total, pop.pheno, sel.crit)
      trait <- pop.pheno
      basepop$pheno <- pop.total$pheno[1:nind, ]
      pop2$pheno <- pop.total$pheno[(nind+1):(nind+nind2)]
      pop3$pheno <- pop.total$pheno[(nind+nind2+1):(nind+nind2+nind3)]
      pop4$pheno <- pop.total$pheno[(nind+nind2+nind3+1):(nind+nind2+nind3+nind4)]
      pop.sir11$pheno <- pop.total$pheno[(nind+nind2+nind3+nind4+1):(nind+nind2+nind3+nind4+nrow(pop.sir11))]
      pop.dam22$pheno <- pop.total$pheno[(nind+nind2+nind3+nind4+nrow(pop.sir11)+1):(nind+nind2+nind3+nind4+nrow(pop.sir11)+nrow(pop.dam22))]
      pop.doubcro$pheno <- pop.total$pheno[(nind+nind2+nind3+nrow(pop.sir11)+nrow(pop.dam22)+1):(nind+nind2+nind3+nind4+nrow(pop.sir11)+nrow(pop.dam22)+nrow(pop.doubcro))]
    }
  
    if (!is.null(out)) {
      flush(geno.sir1)
      flush(geno.dam1)
      flush(geno.sir2)
      flush(geno.dam2)
      flush(geno.sir11)
      flush(geno.dam22)
      flush(geno.doubcro)
    
      # write files
      logging.log("---write files of sir1s---\n", verbose = verbose)
      write.file(basepop, geno.sir1, pos.map, 1:nrow(basepop), 1:nrow(basepop), seed.map, dir.sir1, out.format, verbose)
      logging.log("---write files of dam1s---\n", verbose = verbose)
      write.file(pop2, geno.dam1, pos.map, 1:nrow(pop2), 1:nrow(pop2), seed.map, dir.dam1, out.format, verbose)
      logging.log("---write files of sir2s---\n", verbose = verbose)
      write.file(pop3, geno.sir2, pos.map, 1:nrow(pop3), 1:nrow(pop3), seed.map, dir.sir2, out.format, verbose)
      logging.log("---write files of dam2s---\n", verbose = verbose)
      write.file(pop4, geno.dam2, pos.map, 1:nrow(pop4), 1:nrow(pop4),seed.map, dir.dam2, out.format, verbose)
      logging.log("---write files of sir11s---\n", verbose = verbose)
      write.file(pop.sir11, geno.sir11, pos.map, 1:nrow(pop.sir11), 1:nrow(pop.sir11), seed.map, dir.sir11, out.format, verbose)
      logging.log("---write files of dam22s---\n", verbose = verbose)
      write.file(pop.dam22, geno.dam22, pos.map, 1:nrow(pop.dam22), 1:nrow(pop.dam22), seed.map, dir.dam22, out.format, verbose)
      logging.log("---write files of progenies---\n", verbose = verbose)
      write.file(pop.doubcro, geno.doubcro, pos.map, 1:nrow(pop.doubcro), 1:nrow(pop.doubcro), seed.map, dir.dbc, out.format, verbose)
    }
  
    # set total information of population and genotype
    pop.total <- list(pop.sir1 = basepop, pop.dam1 = pop2, pop.sir2 = pop3, pop.dam2 = pop4, pop.sir11 = pop.sir11, pop.dam22 = pop.dam22, pop.doubcro = pop.doubcro)
    geno.total <- list(geno.sir1 = gc.sir1, geno.dam1 = gc.dam1, geno.sir2 = gc.sir2, geno.dam2 = gc.dam2, geno.sir11 = gc.sir11, geno.dam22 = gc.dam22, geno.doubcro = gc.doubcro)
    
    rm(basepop); rm(basepop.geno); rm(basepop.geno.em); rm(geno.sir1);
    rm(pop2); rm(pop2.geno); rm(pop2.geno.em); rm(geno.dam1);
    rm(pop3); rm(pop3.geno); rm(pop3.geno.em); rm(geno.sir2);
    rm(pop4); rm(pop4.geno); rm(pop4.geno.em); rm(geno.dam2);
    rm(pop.sir11); rm(pop.geno.sir11); rm(pop.geno.sir11.em);
    rm(pop.dam22); rm(pop.geno.dam22); rm(pop.geno.dam22.em);
    rm(pop.gp); rm(pop.doubcro); rm(pop.geno.doubcro); 
    rm(gc.sir1); rm(gc.dam1); rm(gc.sir2); rm(gc.dam2);
    rm(gc.sir11); rm(gc.dam22); rm(gc.doubcro);
    rm(pop.total.temp); gc()

  } else if (mtd.reprod == "backcro") {
    if (num.gen != length(prog.back))
      stop("number of generation should equal to the length of prog.back!")
    out.geno.index <- getindex(count.ind, out.geno.gen)
    out.pheno.index <- getindex(count.ind, out.pheno.gen)

    # store all genotype
    if (!sel.on) {
      geno.total.temp <- big.matrix(
        nrow = num.marker,
        ncol = 2 * sum(count.ind),
        init = 3,
        type = 'char')
    } else {
      geno.total.temp <- NULL
    }
    
    if (!is.null(out)) {
      geno.total <- filebacked.big.matrix(
        nrow = num.marker,
        ncol = sum(count.ind[out.geno.gen]),
        init = 3,
        type = 'char',
        backingpath = directory.rep,
        backingfile = 'genotype.geno.bin',
        descriptorfile = 'genotype.geno.desc')
      options(bigmemory.typecast.warning=FALSE)
    } else {
      geno.total <- big.matrix(
        nrow = num.marker,
        ncol = sum(count.ind[out.geno.gen]),
        init = 3,
        type = 'char')
      options(bigmemory.typecast.warning=FALSE)
    }
 
    # set total population
    pop.total <- rbind(basepop, pop2)
    if (1 %in% out.geno.gen) {
      gc.base <- geno.cvt(basepop.geno)
      gc.pop2 <- geno.cvt(pop2.geno)
      input.geno(geno.total, gc.base, nrow(basepop), mrk.dense)
      input.geno(geno.total, gc.pop2, count.ind[1], mrk.dense)
    }
    if (!sel.on) {
      input.geno(geno.total.temp, basepop.geno, 2*nrow(basepop), mrk.dense)
      input.geno(geno.total.temp, pop2.geno, 2*count.ind[1], mrk.dense)
    }
    logging.log("After generation 1 ,", count.ind[1], "individuals are generated...\n", verbose = verbose)

    if (sel.on) {
      # add selection to generation1
      ind.ordered <-
        selects(pop = basepop,
                decr = decr,
                sel.multi = sel.multi,
                index.wt = index.wt,
                index.tdm = index.tdm,
                goal.perc = goal.perc,
                pass.perc = pass.perc,
                sel.sing = sel.sing,
                pop.total = basepop,
                pop.pheno = pop1.pheno, 
                verbose = verbose)
      index.tdm <- ind.ordered[1]
      ind.ordered <- ind.ordered[-1]
      ind.stay1 <- ind.ordered[1:(count.ind[2]/num.prog)]
      ind.ordered <-
        selects(pop = pop2,
                decr = decr,
                sel.multi = sel.multi,
                index.wt = index.wt,
                index.tdm = index.tdm,
                goal.perc = goal.perc,
                pass.perc = pass.perc,
                sel.sing = sel.sing,
                pop.total = pop2,
                pop.pheno = pop2.pheno, 
                verbose = verbose)
      index.tdm <- ind.ordered[1]
      ind.ordered <- ind.ordered[-1]
      ind.stay2 <- ind.ordered[1:(count.ind[2]/num.prog)]
      ind.stay <- c(ind.stay1, ind.stay2)
    } else {
      ind.stay <- c(basepop$index, pop2$index)
    }
    
    if (num.gen > 1) {
      for (i in 2:num.gen) {
        pop.gp <-
          reproduces(pop1 = basepop,
                     pop2 = pop2,
                     pop1.geno = basepop.geno.em,
                     pop2.geno = pop2.geno.em,
                     ind.stay = ind.stay,
                     mtd.reprod = "singcro",
                     num.prog = num.prog,
                     ratio = ratio)
        
        pop.geno.curr <- pop.gp$geno
        pop.curr <- pop.gp$pop
        isd <- c(2, 5, 6)
        pop.total.temp <- rbind(pop.total[1:sum(count.ind[1:(i-1)]), isd], pop.curr[, isd])
        
        if (sel.on) {
          pop.pheno <-
            phenotype(effs = effs,
                      pop = pop.curr,
                      pop.geno = pop.geno.curr,
                      pos.map = pos.map,
                      h2.tr1 = h2.tr1,
                      gnt.cov = gnt.cov,
                      env.cov = env.cov,
                      sel.crit = sel.crit, 
                      pop.total = pop.total.temp, 
                      sel.on = sel.on, 
                      inner.env =  inner.env, 
                      verbose = verbose)
          pop.curr <- set.pheno(pop.curr, pop.pheno, sel.crit)
          trait[[i]] <- pop.pheno
        }
        
        pop.total <- rbind(pop.total, pop.curr)
        if (i %in% out.geno.gen) {
          gc <- geno.cvt(pop.geno.curr)
          out.gg <- out.geno.gen[1:which(out.geno.gen == i)]
          input.geno(geno.total, gc, sum(count.ind[out.gg]), mrk.dense)
        }
        if (!sel.on) {
          input.geno(geno.total.temp, pop.geno.curr, 2*sum(count.ind[1:i]), mrk.dense)
        }
        logging.log("After generation", i, ",", sum(count.ind[1:i]), "individuals are generated...\n", verbose = verbose)
        
        if (i == num.gen) break
        
        if (sel.on) {
          # output index.tdm and ordered individuals indice
          ind.ordered <-
            selects(pop = pop.curr,
                    decr = decr,
                    sel.multi = sel.multi,
                    index.wt = index.wt,
                    index.tdm = index.tdm,
                    goal.perc = goal.perc,
                    pass.perc = pass.perc,
                    sel.sing = sel.sing,
                    pop.total = pop.total,
                    pop.pheno = pop.pheno, 
                    verbose = verbose)
          index.tdm <- ind.ordered[1]
          ind.ordered <- ind.ordered[-1]
          ind.stay <- c(basepop$index, ind.ordered[1:(count.ind[i+1]/(num.prog*(1-ratio)))])
        } else {
          ind.stay <- c(basepop$index, pop.curr$index)
        }
        
        pop2.geno.em <-  # genotype matrix after Exchange and Mutation
          genotype(geno = pop.geno.curr,
                   blk.rg = blk.rg,
                   recom.spot = recom.spot,
                   range.hot = range.hot,
                   range.cold = range.cold,
                   # recom.cri = "cri3",
                   rate.mut = rate.mut, 
                   verbose = verbose)
        pop2 <- pop.curr
      }  # end for
    }
    
    # if traits have genetic correlation
    # generate phenotype at last
    if (!sel.on) {
      pop.pheno <-
        phenotype(effs = effs,
                  pop = pop.total,
                  pop.geno = geno.total.temp,
                  pos.map = pos.map,
                  h2.tr1 = h2.tr1,
                  gnt.cov = gnt.cov,
                  env.cov = env.cov,
                  sel.crit = sel.crit, 
                  pop.total = pop.total, 
                  sel.on = sel.on, 
                  inner.env =  inner.env, 
                  verbose = verbose)
      pop.total <- set.pheno(pop.total, pop.pheno, sel.crit)
      trait <- pop.pheno
    }
    
    if (!is.null(out)) {
      flush(geno.total)
      # write files
      logging.log("---write files of total population...\n", verbose = verbose)
      write.file(pop.total, geno.total, pos.map, out.geno.index, out.pheno.index, seed.map, directory.rep, out.format, verbose)
    }
    
    if (num.gen > 1) {
      rm(pop.gp); rm(pop.curr); rm(pop.geno.curr); rm(pop.total.temp)
    }
    rm(basepop); rm(basepop.geno); rm(basepop.geno.em); rm(pop2); rm(pop2.geno); 
    rm(pop2.geno.em); rm(geno.total.temp); gc()

  } else if (mtd.reprod == "userped") {

    pop1.geno.copy <- basepop.geno

    if (is.null(userped)) {
      stop("Please input pedigree in the process userped!")
    }
    rawped <- userped
    rawped[is.na(rawped)] <- "0"
    if (as.numeric(rawped[1, 2]) < basepop$index[1]) {
      stop("The index of the first sir should be in index of pop1!")
    }

    # Thanks to YinLL for sharing codes of pedigree sorting
    pedx <- as.matrix(rawped)
    pedx0 <- c(setdiff(pedx[, 2],pedx[, 1]), setdiff(pedx[, 3],pedx[, 1]))

    if(length(pedx0) != 0){
      pedx <- rbind(cbind(pedx0, "0", "0"), pedx)
    }

    pedx <- pedx[pedx[, 1] != "0", ]
    pedx <- pedx[!duplicated(pedx), ]
    pedx <- pedx[!duplicated(pedx[, 1]), ]

    pedx1 <- cbind(1:(ncol(basepop.geno)/2), "0", "0")
    pedx2 <- pedx[!(pedx[, 2] == "0" & pedx[, 3] == "0"), ]
    go = TRUE
    i <- 1
    count.ind <- nrow(pedx1)
    logging.log("After generation", i, ",", sum(count.ind[1:i]), "individuals are generated...\n", verbose = verbose)
    while(go == TRUE) {
      i <- i + 1
      Cpedx <- c(pedx1[, 1])
      idx <- (pedx2[, 2] %in% Cpedx) & (pedx2[, 3] %in% Cpedx)
      if (sum(idx) == 0) {
        logging.log("some individuals in pedigree are not in mating process!\n", verbose = verbose)
        logging.log("they are", pedx2[, 1], "\n", verbose = verbose)
        pedx2 <- pedx2[-c(1:nrow(pedx2)), ]
      } else {
        index.sir <- as.numeric(pedx2[idx, 2])
        index.dam <- as.numeric(pedx2[idx, 3])
        pop.geno.curr <- mate(pop.geno = pop1.geno.copy, index.sir = index.sir, index.dam = index.dam)
        pop1.geno.copy <- cbind(pop1.geno.copy[], pop.geno.curr[])
        pedx1 <- rbind(pedx1, pedx2[idx, ])
        pedx2 <- pedx2[!idx, ]
        count.ind <- c(count.ind, length(index.dam))
        logging.log("After generation", i, ",", sum(count.ind[1:i]), "individuals are generated...\n", verbose = verbose)
      }
      if (class(pedx2) == "character") pedx2 <- matrix(pedx2, 1)
      if (dim(pedx2)[1] == 0) go = FALSE
    }
    ped <- pedx1
    rm(pedx1);rm(pedx2);gc()

    # Create a folder to save files
    if (!is.null(out)) {
      if (!dir.exists(out)) stop("Please check your outpath!")
      if (out.format == "numeric") {
        out = paste0(out, .Platform$file.sep, sum(count.ind), "_Simer_Data_numeric")
      } else if (out.format == "plink"){
        out = paste0(out, .Platform$file.sep, sum(count.ind), "_Simer_Data_plink")
      } else {
        stop("out.format should be 'numeric' or 'plink'!")
      }
      if (!dir.exists(out)) { dir.create(out) }
      
      directory.rep <- paste0(out, .Platform$file.sep, "replication", replication)
      if (dir.exists(directory.rep)) {
        remove_bigmatrix(file.path(directory.rep, "genotype"))
        unlink(directory.rep, recursive = TRUE)
      }
      dir.create(directory.rep)
    }

    index <- ped[, 1]
    out.geno.index <- index
    ped.sir <- ped[, 2]
    ped.dam <- ped[, 3]
    sex <- rep(0, length(index))
    sex[index %in% unique(ped.sir)] <- 1
    sex[index %in% unique(ped.dam)] <- 2
    sex[sex == 0] <- sample(1:2, sum(sex == 0), replace = TRUE)
    fam.temp <- getfam(ped.sir, ped.dam, 1, "pm")
    gen <- rep(1:length(count.ind), count.ind)
    pop.total <- data.frame(gen = gen, index = index, fam = fam.temp[, 1], infam = fam.temp[, 2], sir = ped.sir, dam = ped.dam, sex = sex)
    
    gc <- geno.cvt(pop1.geno.copy)
    if (!is.null(out)) {
      geno.total <- filebacked.big.matrix(
        nrow = num.marker,
        ncol = ncol(gc),
        init = 3,
        type = 'char',
        backingpath = directory.rep,
        backingfile = 'genotype.geno.bin',
        descriptorfile = 'genotype.geno.desc')
      options(bigmemory.typecast.warning=FALSE)
    } else {
      geno.total <- big.matrix(
        nrow = num.marker,
        ncol = ncol(gc),
        init = 3,
        type = 'char')
      options(bigmemory.typecast.warning=FALSE)
    }
    input.geno(geno.total, gc, ncol(geno.total), mrk.dense)

    isd <- c(2, 5, 6)
    pop.pheno <-
      phenotype(effs = effs,
                pop = pop.total,
                pop.geno = pop1.geno.copy,
                pos.map = pos.map,
                h2.tr1 = h2.tr1,
                gnt.cov = gnt.cov,
                env.cov = env.cov,
                sel.crit = sel.crit, 
                pop.total = pop.total[, isd], 
                sel.on = sel.on, 
                inner.env =  inner.env, 
                verbose = verbose)
    pop.total <- set.pheno(pop.total, pop.pheno, sel.crit)
    trait <- pop.pheno
    
    if (!is.null(out)) {
      flush(geno.total)
      logging.log("---write files of total population...\n", verbose = verbose)
      write.file(pop.total, geno.total, pos.map, index, index, seed.map, directory.rep, out.format, verbose)
    }
    
    rm(basepop); rm(basepop.geno); rm(basepop.geno.em); rm(userped); rm(rawped); rm(ped); gc()

  } else {
    stop("Please input correct reproduction method!")
  }

  # total information list
  simer.list <- list(pop = pop.total, effs = effs, trait = trait, geno = geno.total, genoid = out.geno.index, map = pos.map, si = sel.i)
  rm(effs); rm(trait); rm(pop.total); rm(geno.total); rm(input.map); rm(pos.map); gc()
  
  print_accomplished(width = 70, verbose = verbose)
  # Return the last directory
  ed <- Sys.time()
  logging.log(" SIMER DONE WITHIN TOTAL RUN TIME:", format_time(as.numeric(ed)-as.numeric(op)), "\n", verbose = verbose)
  return(simer.list)
}
