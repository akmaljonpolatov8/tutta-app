from rest_framework import permissions, response, views


class PaymentsHealthView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        return response.Response({'detail': 'Payments module is initialized.'})
