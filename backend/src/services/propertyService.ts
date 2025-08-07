import { injectable } from "tsyringe";
import { Services } from "./services";
import { Property, PropertyDocument } from "../models/property";
import { CreatePropertyDto } from "../dtos/property";
import { User } from "../models/user";
import mongoose from "mongoose";

@injectable()
export class PropertyServices extends Services<PropertyDocument> {
  constructor() {
    super(Property);
  }

  public createProperty = async (
    args: CreatePropertyDto
  ): Promise<PropertyDocument> => {
    await this.validateInput(CreatePropertyDto, args);

    const createdProperty = await this.model.create(args);

    return createdProperty;
  };

  public updateProperty = async (
    _id: string,
    args: CreatePropertyDto
  ): Promise<PropertyDocument | null> => {
    const updatedProperty = await this.model.findByIdAndUpdate(_id, args, {
      new: true,
      runValidators: true,
    });

    return updatedProperty;
  };

  public getProperty = async (_id: string, userId: string) => {
    const propertyId = new mongoose.Types.ObjectId(_id);

    const pipeline = [
      // Match the user by ID
      { $match: { _id: new mongoose.Types.ObjectId(userId) } },

      // Filter tokens to only valid ones (not expired)
      {
        $project: {
          validTokens: {
            $filter: {
              input: "$tokenPackages",
              as: "token",
              cond: {
                $and: [
                  { $eq: ["$$token.isExpired", false] },
                  { $gt: ["$$token.expiresAt", new Date()] },
                ],
              },
            },
          },
        },
      },

      // Check if any token has accessed the property
      {
        $project: {
          hasAccess: {
            $gt: [
              {
                $size: {
                  $filter: {
                    input: {
                      $reduce: {
                        input: "$validTokens",
                        initialValue: [],
                        in: {
                          $concatArrays: [
                            "$$value",
                            "$$this.accessedProperties",
                          ],
                        },
                      },
                    },
                    as: "propId",
                    cond: { $eq: ["$$propId.propertyId", propertyId] },
                  },
                },
              },
              0,
            ],
          },
        },
      },

      // Lookup the property document
      {
        $lookup: {
          from: "properties",
          let: { propertyId: propertyId },
          pipeline: [
            {
              $match: {
                $expr: {
                  $and: [
                    { $eq: ["$_id", "$$propertyId"] },
                    { $eq: ["$status", true] },
                  ],
                },
              },
            },
          ],
          as: "property",
        },
      },
      // Unwind property array to object
      { $unwind: "$property" },
      {
        $addFields: {
          userIsOwner: {
            $eq: ["$property.userId", new mongoose.Types.ObjectId(userId)],
          },
        },
      },

      // Project property fields conditionally
      {
        $project: {
          property: {
            _id: 1,
            title: 1,
            description: 1,
            rentAmount: 1,
            images: 1,
            createdAt: 1,
            userId: 1,
            videos: 1,
            type: 1,
            floorLevel: 1,
            size: 1,
            currency: 1,
            paymentFrequency: 1,
            securityDeposit: 1,
            amenities: 1,
            houseRules: 1,
            viewCount: 1,
            // Conditionally include contact and location
            contact: {
              $cond: [
                {
                  $or: [
                    { $eq: ["$hasAccess", true] },
                    { $eq: ["$userIsOwner", true] },
                  ],
                },
                "$property.contact",
                "$$REMOVE",
              ],
            },
            location: {
              $cond: [
                {
                  $or: [
                    { $eq: ["$hasAccess", true] },
                    { $eq: ["$userIsOwner", true] },
                  ],
                },
                "$property.location",
                "$$REMOVE",
              ],
            },
          },
        },
      },
    ];

    const result = await User.aggregate(pipeline).exec();

    if (!result.length) return null;

    return result[0].property;
  };

  public getOwnersProperties = async ({
    userId,
    page,
    limit,
  }: {
    userId: string;
    page: number;
    limit: number;
  }) => {
    const skip = (page - 1) * limit;

    const [properties, total] = await Promise.all([
      this.model
        .find({ userId })
        .select({
          title: 1,
          description: 1,
          rentAmount: 1,
          "location.landmark": 1,
        })
        .skip(skip)
        .limit(limit)
        .sort({ createdAt: -1 }),

      this.model.countDocuments({ userId }),
    ]);

    return {
      data: properties,
      page,
      totalPages: Math.ceil(total / limit),
      total,
    };
  };

  public getPropertyAccess = async (_id: string) => {
    const property = await this.model
      .findOne({ _id, status: true })
      .select("contact location");

    return property;
  };

  public searchPropertiesWithFilters = async (query: {
    page?: number;
    limit?: number;
    location?: { town?: string };
    type?: string;
    maxRent?: number;
    search?: string;
    userId: string;
  }) => {
    const {
      page = 1,
      limit = 10,
      location,
      type,
      maxRent,
      search,
      userId,
    } = query;

    const filters: any = { status: true };

    // Search filter
    if (search) {
      filters.$or = [
        { title: { $regex: search, $options: "i" } },
        { description: { $regex: search, $options: "i" } },
      ];
    }

    // Location filter
    if (location?.town) {
      filters["location.town"] = { $regex: location.town, $options: "i" };
    }

    // Type filter
    if (type) filters.type = type;

    // Max rent filter
    if (maxRent) filters.rentAmount = { $lte: maxRent };

    // --- Step 1: Get user token access ---
    const user = await User.findById(userId).lean();

    if (!user) throw new Error("User not found");

    // Flatten all accessed property IDs from token packages
    const accessedIds =
      user.tokenPackages
        ?.filter((pkg: any) => !pkg.expired) // skip expired packages
        .flatMap((pkg: any) => pkg.accessedProperties || [])
        .map((id: any) => id.toString()) || [];

    // --- Step 2: Fetch filtered properties ---
    const properties = await Property.find(filters, {
      _id: 1,
      type: 1,
      size: 1,
      title: 1,
      description: 1,
      currency: 1,
      paymentFrequency: 1,
      rentAmount: 1,
      images: 1,
      userId: 1,
      createdAt: 1,
    })
      .skip((page - 1) * limit)
      .limit(limit)
      .sort({ createdAt: -1 })
      .lean();

    // --- Step 3: Mark hasAccess based on token ---
    const updatedProperties = properties.map((prop: any) => ({
      ...prop,
      hasAccess: accessedIds.includes(prop._id.toString()),
    }));

    const total = await Property.countDocuments(filters);

    return {
      data: updatedProperties,
      pagination: {
        page,
        limit,
        totalPages: Math.ceil(total / limit),
        total,
      },
    };
  };

  public async getNearbyProperties({
    lng,
    lat,
    maxDistanceInMeters = 5000,
  }: {
    lng: number;
    lat: number;
    maxDistanceInMeters?: number;
  }) {
    if (
      typeof lng !== "number" ||
      typeof lat !== "number" ||
      isNaN(lng) ||
      isNaN(lat)
    ) {
      throw new Error("Invalid longitude or latitude");
    }

    const results = await this.model.aggregate([
      {
        $geoNear: {
          near: { type: "Point", coordinates: [lng, lat] },
          distanceField: "dist.calculated", // Required by $geoNear but will be removed later
          maxDistance: maxDistanceInMeters,
          spherical: true,
        },
      },
      {
        $project: {
          _id: 1,
          title: 1,
          location: {
            coordinates: 1,
            street: "$location.street",
            landmark: "$location.landmark",
          },
        },
      },
    ]);

    return results;
  }
}
