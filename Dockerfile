# Use official Python image
FROM python:3.9

# Set working directory inside container
WORKDIR /app

# Copy application files
COPY . .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose Flask port
EXPOSE 5000

# Run Gunicorn server (instead of Flask dev server)
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "app.app:app"]