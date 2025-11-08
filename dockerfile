# Use AWS Lambda Python runtime base image
FROM public.ecr.aws/lambda/python:3.9

# Install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

# Copy app code
COPY . ${LAMBDA_TASK_ROOT}

# Set handler (filename.function)
CMD ["Task.handler"]
