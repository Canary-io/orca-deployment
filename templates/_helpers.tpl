{{- define "service-chart.name" -}}
{{- default .Chart.Name .Values.image.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "service-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "service-chart.image" -}}
{{- if .Values.image.repository -}}
{{- printf "%s:%s" .Values.image.repository .Values.image.tag -}}
{{- else -}}
{{- printf "%s/%s/%s:%s" .Values.image.registry .Values.image.owner .Values.image.name .Values.image.tag -}}
{{- end -}}
{{- end }}

{{- define "service-chart.canaryServiceName" -}}
{{- $name := default "app" (include "service-chart.name" .) -}}
{{ printf "%s-canary" $name }}
{{- end }}

{{- define "service-chart.stableServiceName" -}}
{{- $name := default "app" (include "service-chart.name" .) -}}
{{ printf "%s-stable" $name }}
{{- end }}

{{- define "service-chart.labels" -}}
helm.sh/chart: {{ include "service-chart.chart" . }}
{{ include "service-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "service-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "service-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
