@echo off
chcp 65001 >nul
latexmk -pdf -pvc -interaction=nonstopmode -cd %1
