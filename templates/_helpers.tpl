{{- define "service-chart.name" -}}
{{- default .Release.Name .Values.image.name | trunc 63 | trimSuffix "-" }}
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

{{- define "service-chart.ingressHost" -}}
{{- if .Values.ingress.host -}}
{{- .Values.ingress.host -}}
{{- else -}}
{{- printf "%s.%s" .Release.Name .Values.ingress.domain -}}
{{- end -}}
{{- end }}

{{- define "service-chart.metricsHost" -}}
{{- if .Values.metrics.host -}}
{{- .Values.metrics.host -}}
{{- else -}}
{{- $appHost := include "service-chart.ingressHost" . -}}
{{- $parts := splitList "." $appHost -}}
{{- if gt (len $parts) 1 -}}
{{- printf "%s-metrics.%s" (index $parts 0) (join "." (slice $parts 1)) -}}
{{- else -}}
{{- printf "%s-metrics" $appHost -}}
{{- end -}}
{{- end -}}
{{- end }}

{{- define "service-chart.metricsServiceName" -}}
{{- printf "%s-metrics" (include "service-chart.name" .) -}}
{{- end }}

{{- define "service-chart.grafanaHost" -}}
{{- if .Values.grafanaDashboard.ingress.host -}}
{{- .Values.grafanaDashboard.ingress.host -}}
{{- else -}}
{{- $appHost := include "service-chart.ingressHost" . -}}
{{- $parts := splitList "." $appHost -}}
{{- if gt (len $parts) 1 -}}
{{- printf "%s-grafana.%s" (index $parts 0) (join "." (slice $parts 1)) -}}
{{- else -}}
{{- printf "%s-grafana" $appHost -}}
{{- end -}}
{{- end -}}
{{- end }}

{{- define "service-chart.grafanaDashboardUid" -}}
{{- printf "%s-metrics" .Values.image.name | lower | replace "_" "-" | trunc 40 | trimSuffix "-" -}}
{{- end }}

{{- define "service-chart.shouldCreateGrafanaIngress" -}}
{{- $host := include "service-chart.grafanaHost" . -}}
{{- $path := .Values.grafanaDashboard.ingress.path | default "/" -}}
{{- $name := printf "%s-grafana-ingress" (include "service-chart.name" .) -}}
{{- $namespace := "argo-rollouts" -}}
{{- $shouldCreate := true -}}
{{- $ingresses := (lookup "networking.k8s.io/v1" "Ingress" "" "") -}}
{{- if $ingresses }}
  {{- range $ing := $ingresses.items }}
    {{- if not (and (eq $ing.metadata.name $name) (eq $ing.metadata.namespace $namespace)) }}
      {{- range $rule := $ing.spec.rules }}
        {{- if eq $rule.host $host }}
          {{- range $p := $rule.http.paths }}
            {{- if eq $p.path $path }}
              {{- $shouldCreate = false -}}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- if $shouldCreate }}true{{ else }}false{{ end }}
{{- end }}
