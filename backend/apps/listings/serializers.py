from rest_framework import serializers

from .models import Listing, ListingImage


class ListingImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ListingImage
        fields = ('id', 'image', 'created_at')
        read_only_fields = ('id', 'created_at')


class ListingSerializer(serializers.ModelSerializer):
    images = ListingImageSerializer(many=True, read_only=True)
    host_id = serializers.IntegerField(source='host.id', read_only=True)

    class Meta:
        model = Listing
        fields = (
            'id',
            'host_id',
            'title',
            'description',
            'location',
            'listing_type',
            'price_per_night',
            'max_guests',
            'is_active',
            'images',
            'created_at',
            'updated_at',
        )
        read_only_fields = ('id', 'host_id', 'is_active', 'created_at', 'updated_at')

    def create(self, validated_data):
        return Listing.objects.create(host=self.context['request'].user, **validated_data)


class ListingCreateSerializer(serializers.ModelSerializer):
    image_files = serializers.ListField(
        child=serializers.ImageField(),
        required=False,
        allow_empty=True,
        write_only=True,
    )

    class Meta:
        model = Listing
        fields = (
            'id',
            'title',
            'description',
            'location',
            'listing_type',
            'price_per_night',
            'max_guests',
            'image_files',
            'created_at',
            'updated_at',
        )
        read_only_fields = ('id', 'created_at', 'updated_at')

    def create(self, validated_data):
        image_files = validated_data.pop('image_files', [])
        listing = Listing.objects.create(host=self.context['request'].user, **validated_data)
        for image in image_files:
            ListingImage.objects.create(listing=listing, image=image)
        return listing

    def to_representation(self, instance):
        return ListingSerializer(instance, context=self.context).data
