FROM public.ecr.aws/lambda/python:3.9
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt --target "/var/task"
COPY . /var/task
# Replace module.function with your handler (file.py -> function)
CMD ["app.lambda_handler"]
