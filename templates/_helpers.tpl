{{- define "service-chart.name" -}}
{{- default .Values.image.name  .Release.Name| trunc 63 | trimSuffix "-" }}
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

{{- define "service-chart.metricsServiceName" -}}
{{- $name := default "app" (include "service-chart.name" .) -}}
{{ printf "%s-metrics" $name }}
{{- end }}

{{- define "service-chart.ingressHost" -}}
{{- if .Values.ingress.host -}}
{{- .Values.ingress.host -}}
{{- else -}}
{{- printf "%s.%s" (include "service-chart.name" .) .Values.ingress.domain -}}
{{- end -}}
{{- end }}

{{- define "service-chart.metricsHost" -}}
{{- if .Values.metrics.host -}}
{{- .Values.metrics.host -}}
{{- else -}}
{{- printf "%s-metrics.%s" (include "service-chart.name" .) .Values.ingress.domain -}}
{{- end -}}
{{- end }}

{{- define "service-chart.grafanaHost" -}}
{{- if .Values.grafanaDashboard.ingress.host -}}
{{- .Values.grafanaDashboard.ingress.host -}}
{{- else -}}
{{- printf "%s-grafana.%s" (include "service-chart.name" .) .Values.ingress.domain -}}
{{- end -}}
{{- end }}

{{- define "service-chart.grafanaDashboardUid" -}}
{{- printf "%s-dashboard" (include "service-chart.name" .) | trunc 40 | trimSuffix "-" -}}
{{- end }}

{{- define "service-chart.grafanaDashboardSlug" -}}
{{- printf "%s-metrics" .Values.image.name | lower | replace " " "-" | replace "_" "-" | trunc 40 | trimSuffix "-" -}}
{{- end }}

{{- define "service-chart.shouldCreateGrafanaIngress" -}}
{{- if and .Values.grafanaDashboard.enabled .Values.grafanaDashboard.ingress.enabled -}}
true
{{- else -}}
false
{{- end -}}
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
