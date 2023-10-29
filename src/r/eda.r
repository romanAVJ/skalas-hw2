##############################################################
# eda for ecobici 
# @roman_avj                                          29-oct-23
##############################################################
# libraries
library(tidyverse)
library(lubridate)


#### read data ####
df_ecobici  <- read_csv("data/ecobici_02.csv")
# df_ecobici  <- read_csv("data/2023ecobici.csv")
df_ecobici  <- df_ecobici |> rename(Fecha_Arribo = `Fecha Arribo`) # rename column

#### skalas questions ####
# q1: Tiempo promedio por recorrido
df_ecobici  <- df_ecobici |> 
    mutate(
        # arrival_date = Fecha Arribo, Hora Arribo,
        arrival_date = strptime(paste(Fecha_Arribo, Hora_Arribo), "%d/%m/%Y %H:%M:%S"),
        departure_date = strptime(paste(Fecha_Retiro, Hora_Retiro), "%d/%m/%Y %H:%M:%S"),
        # time
        ride_time = difftime(arrival_date, departure_date, units = "mins")
    )

cat("Minutos promedio: ", mean(df_ecobici$ride_time, na.rm = TRUE))

# q2: tiempo promedio recorrido por sexo
cat("Minutos promedio por sexo")
df_ecobici |> 
    group_by(Genero_Usuario) |> 
    summarise(mean_ride_time = mean(ride_time, na.rm = TRUE))

# q3: tiempo promedio recorrido por hora
cat("Minutos promedio por hora")
table_hour  <- df_ecobici |>
    mutate(retire_hour = hour(Hora_Retiro)) |>
    group_by(retire_hour) |> 
    summarise(mean_ride_time = mean(ride_time, na.rm = TRUE)) |> 
    mutate(mean_ride_time = as.double(mean_ride_time)) |>
    arrange(desc(mean_ride_time))

# plot polar col graph
table_hour |> 
    ggplot(aes(x = retire_hour, y = mean_ride_time)) + 
    geom_col(fill = "steelblue", color = "black", alpha = 0.5) + 
    scale_x_continuous(breaks = seq(0, 23, 1), labels = seq(0, 23, 1)) +
    coord_polar() + 
    labs(title = "Minutos promedio por hora", x = "Hora", y = "Minutos")

# q4: Recorridos por día de la semana
cat("Recorridos por día de la semana")
table_date  <- df_ecobici |> 
    # get day of the week
    mutate(retaire_day = wday(Fecha_Retiro, label = TRUE)) |>
    count(retaire_day)

# plot bar 
table_date |> 
    ggplot(aes(x = retaire_day, y = n)) + 
    geom_col(fill = "steelblue", color = "black", alpha = 0.5) +     coord_polar() + 
    labs(title = "Distribución de Recorridos por Día de la Semana", x = "Día", y = "Conteo")

# q5: Recorridos más comunes
cat("Los 5 recorridos más comunes")
df_ecobici |> 
    count(Ciclo_Estacion_Retiro, Ciclo_EstacionArribo) |> 
    arrange(desc(n)) |> 
    rename(viajes = n) |>
    head(5)

#### own questions ####
# q6: time series of rides
cat("Distribución de recorridos anual")
table_rides <- df_ecobici |> 
    mutate(retire_date = dmy(Fecha_Retiro)) |>
    count(retire_date) |>
    rename(rides = n)

# plot time series
table_rides |> 
    filter(retire_date > "2023-01-01") |>
    mutate(retire_date = as.Date(retire_date, format = "%Y-%m-%d")) |>
    ggplot(aes(x = retire_date, y = rides)) + 
    geom_line(color = "steelblue", alpha = 0.5) +
    scale_x_date(date_breaks = "1 month", date_labels = "%b", minor_breaks = "1 week") +
    labs(title = "Series de tiempo de recorridos", x = "Fecha", y = "Recorridos")

# q7: which factors affects more the ride time
cat("Factores que afectan más el tiempo de recorrido")
set.seed(8)
table_hour  <- df_ecobici |>
    slice_sample(n = 100000) |> 
    mutate(
        retire_hour = hour(Hora_Retiro),
        retire_day = wday(Fecha_Retiro, label = TRUE),
        ride_time = as.double(ride_time)
        )

fitlm  <- glm(
    ride_time ~ retire_hour + retire_day + Genero_Usuario + Edad_Usuario, 
    data = table_hour,
    family = Gamma(link = "log")
    )
summary(fitlm)

# q8: age distribution
cat("Distribución de edad")
set.seed(8)
df_ecobici |> 
    slice_sample(n = 100000) |>
    ggplot(aes(x = Edad_Usuario)) + 
    geom_histogram(bins = 20, fill = "steelblue", color = "black", alpha = 0.5) + 
    labs(title = "Distribución de edad", x = "Edad", y = "Conteo")

# q9: average day of the week (use directional data)
cat("Día promedio de la semana por Sexo")
table_day_week <- df_ecobici |> 
    mutate(
        retire_day = wday(Fecha_Retiro, label = FALSE),
        cos_day = cos(2 * pi * retire_day / 7),
        sin_day = sin(2 * pi * retire_day / 7)
        ) |>
    group_by(Genero_Usuario) |>
    summarise(
        mean_day = atan2(mean(sin_day), mean(cos_day)) * 7 / (2 * pi),
        mean_day = ifelse(mean_day < 0, mean_day + 7, mean_day),
        sd_day = 1 - sqrt(mean(cos_day)^2 + mean(sin_day)^2)
        )
table_day_week

# Q10: average hour of the day (use directional data)
cat("Hora promedio del día por Sexo")
table_hour_day <- df_ecobici |> 
    mutate(
        retire_hour = hour(Hora_Retiro),
        cos_hour = cos(2 * pi * retire_hour / 24),
        sin_hour = sin(2 * pi * retire_hour / 24)
        ) |>
    group_by(Genero_Usuario) |>
    summarise(
        mean_hour = atan2(mean(sin_hour), mean(cos_hour)) * 24 / (2 * pi),
        mean_hour = ifelse(mean_hour < 0, mean_hour + 24, mean_hour),
        sd_hour = 1 - sqrt(mean(cos_hour)^2 + mean(sin_hour)^2)
        )
table_hour_day

#### finish ####
cat("Finish Stats")

