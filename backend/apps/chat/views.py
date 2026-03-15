from rest_framework import permissions, response, views


class ChatHealthView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        return response.Response({'detail': 'Chat module is initialized.'})
