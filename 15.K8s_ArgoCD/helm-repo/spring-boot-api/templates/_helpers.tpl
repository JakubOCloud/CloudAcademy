{{- define "spring-boot-api.name" -}}
{{- .Chart.Name -}}
{{- end }}

{{- define "spring-boot-api.fullname" -}}
{{- .Release.Name -}}
{{- end }}

{{- define "spring-boot-api.labels" -}}
app.kubernetes.io/name: {{ include "spring-boot-api.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}