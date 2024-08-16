{{- define "capitalizeFirst" -}}
{{- $chars := splitList "" . -}}
{{- $first := upper (index $chars 0) -}}
{{- printf "%s%s" $first (join "" (slice $chars 1)) -}}
{{- end -}}

{{- define "retryFunction" -}}
function retry {
  local retries=$1
  local delay=$2
  shift 2
  
  local count=0
  local success=false
  local result
  
  until [ $count -ge $retries ]; do
    result=$("$@") && success=true || success=false
    if [ "$success" = true ]; then
      echo "$result"
      return 0
    fi

    wait=$((delay ** count))
    count=$((count + 1))
    echo "Retry $count/$retries failed. Retrying in $wait seconds..."
    sleep $wait
  done

  echo "Command failed after $retries retries."
  return 1
}
{{- end -}}
