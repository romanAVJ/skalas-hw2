# !/bin/bash
# ----------------------------------------------------------------------
# Code to get general stats from the data
# 28 oct 2023                                           @roman_avj
# ----------------------------------------------------------------------
# step 0: functions
get_counts() {
    # get counts for a column
    # $1: column

    # get rid of header and empty lines and save it to a var
    xvar=$(echo "$1" | tail -n +2 | grep -v '^\s*$' | grep -v 'NULL')

    # get counts
    echo "$xvar" | sort | uniq -c | sort -nr | head -n 3
}

get_numerical_stats() {
    # get min, max, mean, std for a column
    # $1: column

    # get rid of header and empty lines and save it to a var
    xvar=$(echo "$1" | tail -n +2 | grep -v '^\s*$' | grep -v 'NULL')

    # Pre-process the data to remove non-numeric characters using sed
    xvar=$(echo "$xvar" | sed 's/[^0-9. -]//g')
    
    # Use awk with xvar for numerical stats calculation
    echo "$xvar" | awk 'BEGIN {min=9999999; max=0; sum=0; sumsq=0; count=0}
    { 
        count++;
        sum+=$1; 
        sumsq+=$1*$1; 
        if ($1 < min) min=$1; 
        if ($1 > max) max=$1;
        a[$1]++;
    }
    END { 
        if (count > 0) {
            print "min: " min;
            print "max: " max;
            print "mean: " sum/count;
            print "std: " sqrt(sumsq/count - (sum/count)^2);
            # get count how many values are after mean + 2*std
            count_after=0;
            for (i in a) {
                if (i > sum/count + 3*sqrt(sumsq/count - (sum/count)^2)) {
                    count_after+=a[i]; # add the count of the value
                }
            }
            print "outliers after " sum/count + 3*sqrt(sumsq/count - (sum/count)^2);
            print "percent outliers " count_after/count * 100 "%";
        } else {
            print "No valid numerical data found in the column.";
        }
    }'
}

get_cyclical_stats() {
    # get min, max, mean, std for a column
    # $1: column

    # get rid of header and empty lines and save it to a var
    xvar=$(echo "$1" | tail -n +2 | grep -v '^\s*$' | grep -v 'NULL')

    # Pre-process the data and get hour
    xvar=$(echo "$xvar" | cut -d : -f 1)

    # echo $xvar

    # Use awk with xvar for cyclical stats calculation
    echo "$xvar" | awk 'BEGIN {min=99999; max=0; count=0; sumcos=0; sumsine=0}
        { 
            count++;
            angle = $1 * 2 * 3.1416 / 24;
            sumcos += cos(angle);
            sumsine += sin(angle);
            if ($1 < min) min = $1;
            if ($1 > max) max = $1;
        }
        END {
            print "min: " min;
            print "max: " max;
            mean_radians = atan2(sumsine, sumcos);
            if (mean_radians < 0) {
                mean_radians += 2 * 3.1416;
            }
            mean_hours = mean_radians * 24 / (2 * 3.1416);
            print "mean: " mean_hours;
            std = 1 - sqrt(sumcos^2 + sumsine^2) / count;
            print "std: " std * 24 / (2 * 3.1416);
        }'
}

# Step 1: Read data
echo "reading data ..."

# read data
data_file="data/ecobici_02.csv"

# Step 2: get counts for column 1: Genero_Usuario
echo ""
echo "Genero_Usuario ..."
# get column
column=$(cut -d , -f 1 "$data_file")
# get counts in descending order
get_counts "$column"

# Step 3: get mean and std for column 2: Edad_Usuario
echo ""
echo "Edad_Usuario ..."
# get column
column=$(cut -d , -f 2 "$data_file")
# get mean and std
get_numerical_stats "$column"

# Step 4: get counts for column 3: Bici
echo ""
echo "Bici ..."
# get column
column=$(cut -d , -f 3 "$data_file")
# get counts in descending order
get_counts "$column"

# Step 5: get counts for column 4: Ciclo_Estacion_Retiro
echo ""
echo "Ciclo_Estacion_Retiro ..."
# get column
column=$(cut -d , -f 4 "$data_file")
# get counts in descending order
get_counts "$column"

# Step 6: get counts for column 7: Ciclo_Estacion_Arribo
echo ""
echo "Ciclo_Estacion_Arribo ..."
# get column
column=$(cut -d , -f 7 "$data_file")
# get counts in descending order
get_counts "$column"

# Step 7: get mean and std for column 8: Hora_Retiro
echo ""
echo "Hora_Retiro ... (estadísticas direccionales)"
# get column
column=$(cut -d , -f 6 "$data_file")
# get mean and std
get_cyclical_stats "$column"

Step 8: get mean and std for column 9: Hora_Arribo
echo ""
echo "Hora_Arribo ... (estadísticas direccionales)"
# get column
column=$(cut -d , -f 9 "$data_file")
get_cyclical_stats "$column"