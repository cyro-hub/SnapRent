import { injectable } from "tsyringe";
import { ValidationErrorDetails } from "./errorService";

export interface IApiResponse<T> {
  state: boolean;
  data?: T;
  message: string;
  page?: number;
  pageSize?: number;
  totalPages?: number;
  hasNextPage?: boolean;
  validationErrorResponse?: ValidationErrorDetails[];
}

@injectable()
export default class ApiResponse<T> {
  private state: boolean = false;
  private data?: T = undefined;
  private message: string = "Ok";
  private page?: number;
  private pageSize?: number;
  private totalPages?: number;
  private hasNextPage?: boolean;
  private validationErrorResponse?: ValidationErrorDetails[];

  public setFailedResponse(
    message: string,
    error: ValidationErrorDetails[] = []
  ): void {
    this.state = false;
    this.message = message;
    this.validationErrorResponse = error;
  }

  public setSuccessfulResponse(message: string, data: T): void {
    this.state = true;
    this.message = message;
    this.data = data;
  }

  public setSuccessfulPageResponse(
    message: string,
    data: T,
    page: number,
    pageSize: number,
    totalPages: number
  ): void {
    this.state = true;
    this.message = message;
    this.data = data;
    this.page = page;
    this.pageSize = pageSize;
    this.totalPages = totalPages;
    this.hasNextPage = page < totalPages;
  }

  public toJSON(): object {
    return {
      state: this.state,
      data: this.data,
      message: this.message,
      page: this.page,
      pageSize: this.pageSize,
      totalPages: this.totalPages,
      hasNextPage: this.hasNextPage,
      validationErrorResponse: this.validationErrorResponse,
    };
  }
}
