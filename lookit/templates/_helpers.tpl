{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified postgresql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "postgresql.fullname" -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "environment" }}
- name: DB_NAME
  value: {{ .Values.postgresql.postgresDatabase | quote }}
- name: DB_USER
  value: {{ .Values.postgresql.postgresUser | quote }}
- name: DB_HOST
  value: {{ template "postgresql.fullname" . }}
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ template "postgresql.fullname" . }}
      key: postgres-password
{{- range $key, $val := .Values.environment }}
- name: {{ $key }}
  value: {{ $val | quote }}
{{- end }}
{{- $fullname := include "fullname" . -}}
{{- range tuple "AWS_ACCESS_KEY_ID" "AWS_SECRET_ACCESS_KEY" "EMAIL_HOST_USER" "EMAIL_HOST_PASSWORD" "RAVEN_DSN" }}
- name: {{ . }}
  valueFrom:
    secretKeyRef:
      name: {{ $fullname }}
      key: {{ . }}
{{- end }}
{{- end -}}
