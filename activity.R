library(lubridate)
library(dplyr)
library(VIM)
library(ggplot2)

#loading and transformation of data

activity = read.csv("activity.csv")
activity = activity %>% transform(date = as.Date(date))
activity = tbl_df(activity)

#calculating the total number of steps on each day and mean

activity1 = activity %>% group_by(date) %>% summarize(steps_sum = sum(steps))
hist(activity1$steps_sum, col = 'red', xlab = "Total Number of steps taken per Day", main = "Histogram of Total Number of steps taken per Day")

# calculating of the mean and median number of steps each day

mean_steps = mean(activity1$steps_sum, na.rm = TRUE)
median_steps = median(activity1$steps_sum, na.rm = TRUE)

# time series plot containing the average number of steps for each 5 minute interval all day

activity2 = activity %>% group_by(interval) %>% summarize(Average_steps = mean(steps, na.rm = TRUE))
plot(activity2$interval, activity2$Average_steps, type = "l", xlab = "5 - Minute Interval", 
     ylab = "Average Number of steps taken", main = "Time - Series Plot of Average number of Steps taken in 5 minute interval")

# The 5-minute interval that, on average, contains the maximum number of steps

max_interval = activity2$interval[which.max(activity2$Average_steps)]

# Code for describing and imputing missing data

imputed_data = kNN(activity, variable = "steps")

# Histogram plot with new imputed data

impute_plot = imputed_data %>% group_by(date) %>% summarize(steps_sum = sum(steps))
hist(impute_plot$steps_sum, col = 'red', xlab = "Total Number of steps taken per Day", main = "Histogram of Total Number of steps taken per Day", ylim = c(0, 30))

# Calculating the mean and median number of steps per day with the new imputed data

mean_steps_impute = mean(impute_plot$steps_sum)
median_steps_impute = median(impute_plot$steps_sum)

# Creating a new factor variable with WeekType

imputed_data$Day = weekdays(imputed_data$date)
imputed_data$WeekType = "weekday"
imputed_data$WeekType[imputed_data$Day %in% c("Saturday", "Sunday")] = "weekend"

grouped_dataset = imputed_data %>% group_by(WeekType, interval) %>% summarize(steps_sum = mean(steps))
qplot(interval, steps_sum, data = grouped_dataset, geom = "line", facets = WeekType~., xlab = "Interval", ylab = "Number of Steps", main = "Average Number of Steps Weekdays VS Weekends")
