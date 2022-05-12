# Formatting days as months + days
print_days_months <- function(days, long = FALSE) {
  m_str <- ifelse(long, " months ", "m ")
  d_str <- ifelse(long, " days", "d")
  days_per_month <- 30.417
  months <- days %/% days_per_month
  days_left <- as.integer(days - months * days_per_month)
  str <- paste0(as.character(months), m_str, as.character(days_left), d_str)
  str[is.na(days)] <- NA
  return(str)
}

# Formatting percentages with one decimal place
print_perc <- function(x) scales::percent(x, accuracy = 0.1)

# Formatting numbers with a certain number of decimal places
print_num <- function(x, digits = 2) {
  x <- format(round(x, digits), trim = TRUE, nsmall = digits)
  x[x == "NA"] <- NA
  return(x)
}

# Format confidence interval
print_ci <- function(lb, ub) {
  paste0("[", print_num(lb), ", ", print_num(ub), "]")
}

# Format mean value and confidence interval
print_mean_ci <- function(mean, lb, ub) {
  paste(print_num(mean), print_ci(lb, ub))
}

# Format results of Bayesian meta-analsis as a table with optional labels
print_res_table <- function(res,
                            label_1 = NULL,
                            label_2 = NULL,
                            label_col_1 = "label_1",
                            label_col_2 = "label_2") {
  spread_draws(res, `b_.*`, `sd_.*`, regex = TRUE, ndraws = NULL) %>%
    transmute(
      `Hedges' $g$` = b_Intercept,
      `$\\sigma_\\text{article}^2$` = sd_article__Intercept^2,
      `$\\sigma_\\text{experiment}^2$` = `sd_article:experiment__Intercept`^2,
      `${ICC}$` = `$\\sigma_\\text{article}^2$` /
        (`$\\sigma_\\text{article}^2$` + `$\\sigma_\\text{experiment}^2$`)
    ) %>%
    summarize(across(.fns = mean_qi)) %>%
    map_dfc(~ print_mean_ci(.$y, .$ymin, .$ymax)) -> tab
  if (!is.null(label_2)) {
    label_2_tab <- tibble(tmp = c(label_2, rep(NA, nrow(tab) - 1))) %>%
      rename(!!label_col_2 := tmp)
    tab <- cbind(label_2_tab, tab)
  }
  if (!is.null(label_1)) {
    label_1_tab <- tibble(tmp = c(label_1, rep(NA, nrow(tab) - 1))) %>%
      rename(!!label_col_1 := tmp)
    tab <- cbind(label_1_tab, tab)
  }
  return(tab)
}

# Format results of Bayesian meta-regression as a table with optional labels
print_res_reg_table <- function(res_reg,
                                label_1 = NULL,
                                label_2 = NULL,
                                label_col_1 = "label_1",
                                label_col_2 = "label_2") {
  spread_draws(res_reg, `b_.*`, `sd_.*`, regex = TRUE, ndraws = NULL) %>%
    transmute(
      `Intercept` = b_Intercept,
      `Female - mixed` = b_gender2M1,
      `Male - female` = b_gender3M2,
      `Age (per year)` = b_age_c,
      `Habituation - VoE` = b_task2M1,
      `[Female - mixed] $\\times$ age` = `b_gender2M1:age_c`,
      `[Male - female] $\\times$ age` = `b_gender3M2:age_c`
    ) %>%
    summarize(across(.fns = mean_qi)) %>%
    map_dfc(~ print_mean_ci(.$y, .$ymin, .$ymax)) -> tab
  if (!is.null(label_2)) {
    label_2_tab <- tibble(tmp = c(label_2, rep(NA, nrow(tab) - 1))) %>%
      rename(!!label_col_2 := tmp)
    tab <- cbind(label_2_tab, tab)
  }
  if (!is.null(label_1)) {
    label_1_tab <- tibble(tmp = c(label_1, rep(NA, nrow(tab) - 1))) %>%
      rename(!!label_col_1 := tmp)
    tab <- cbind(label_1_tab, tab)
  }
  return(tab)
}

# Format results of frequentist meta-analsis as a table with optional labels
print_res_freq_table <- function(res_freq,
                                 label_1 = NULL,
                                 label_2 = NULL,
                                 label_col_1 = "label_1",
                                 label_col_2 = "label_2",
                                 print_sigma2s = TRUE) {
  tibble(
    Parameter = rownames(res_freq$b),
    Estimate = print_num(as.numeric(res_freq$b)),
    `$SE$` = print_num(res_freq$se),
    `$z$` = print_num(res_freq$zval),
    `$p$` = papaja::print_p(res_freq$pval),
    ci_lower = print_num(res_freq$ci.lb),
    ci_upper = print_num(res_freq$ci.ub)
  ) %>%
    mutate(
      `95\\% CI` = str_c("[", ci_lower, ", ", ci_upper, "]"),
      .keep = "unused"
    ) -> tab
  if (!is.null(label_2)) {
    label_2_tab <- tibble(tmp = c(label_2, rep(NA, nrow(tab) - 1))) %>%
      rename(!!label_col_2 := tmp)
    tab <- cbind(label_2_tab, tab)
  }
  if (!is.null(label_1)) {
    label_1_tab <- tibble(tmp = c(label_1, rep(NA, nrow(tab) - 1))) %>%
      rename(!!label_col_1 := tmp)
    tab <- cbind(label_1_tab, tab)
  }
  if (print_sigma2s) {
    tab <- bind_rows(tab, tibble(
      Parameter = res_freq$s.name,
      Estimate = print_num(res_freq$sigma2)
    ))
  }
  return(tab)
}