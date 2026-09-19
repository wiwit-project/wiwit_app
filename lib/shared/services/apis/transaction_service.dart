import 'package:chopper/chopper.dart';

import '../../models/wiwit_api/transactions/add_transaction_request.dart';
import '../../models/wiwit_api/transactions/transaction_list_response.dart';
import '../../models/wiwit_api/transactions/transaction_response.dart';

part 'transaction_service.chopper.g.dart';

@ChopperApi(baseUrl: '/api/v1/transactions')
abstract class TransactionService extends ChopperService {
  static TransactionService create([ChopperClient? client]) =>
      _$TransactionService(client);

  @GET()
  Future<TransactionListResponse> getTransactions({
    @Query() int? page,
    @Query('per_page') int? perPage,
    @Query() String? type,
    @Query('category_id') int? categoryId,
    @Query('date_from') String? dateFrom,
    @Query('date_to') String? dateTo,
  });

  @POST()
  Future<TransactionResponse> createTransaction(
    @Body() AddTransactionRequest body,
  );

  @GET(path: '/{id}')
  Future<TransactionResponse> getTransaction(@Path() int id);

  @PATCH(path: '/{id}')
  Future<Response> updateTransaction(
    @Path() int id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE(path: '/{id}')
  Future<Response> deleteTransaction(@Path() int id);
}
