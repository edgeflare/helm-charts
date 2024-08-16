{{- define "capitalizeFirst" -}}
{{- $chars := splitList "" . -}}
{{- $first := upper (index $chars 0) -}}
{{- printf "%s%s" $first (join "" (slice $chars 1)) -}}
{{- end -}}