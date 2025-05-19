FROM public.ecr.aws/lambda/nodejs18.x

# Copy function code
COPY . ${LAMBDA_TASK_ROOT}

# Install dependencies
RUN npm install

# Command to run the Lambda function
CMD [ "index.handler" ]