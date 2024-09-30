# # Extract the seventh field from /etc/passwd into an array
# unformd_bins=($(awk -F: '{print $7}' /etc/passwd))
# # Declare an associative array to track unique items
# declare -A sorting_bins
# # Iterate over the original array and store unique items
# for i in "${unformd_bins[@]}"; do
#     sorting_bins["$i"]=420
# done
# # Create a new array with unique items
# unique_array=("${!sorting_bins[@]}")
# # Print the unique array
# echo "${unique_array[@]}"



# Start the echo command in the background
for i in {1..10}; do
  echo $i
  sleep 0.1  # Optional: add a small delay for better readability
done &

# Run another command concurrently
echo hello
