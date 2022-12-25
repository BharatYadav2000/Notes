 FROM python:latest
WORKDIR /today
COPY . .
ENV PORT=8000
EXPOSE 8000
CMD ["python", "index.py"]





