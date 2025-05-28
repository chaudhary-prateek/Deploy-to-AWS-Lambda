FROM public.ecr.aws/lambda/nodejs:20

# Copy function code
COPY . ${LAMBDA_TASK_ROOT}

# Install dependencies
RUN npm install

# Command to run the Lambda function
CMD [ "index.handler" ]
