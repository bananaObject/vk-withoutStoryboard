//
//  PostModel.swift
//  vk-withoutStoryboard
//
//  Created by Ke4a on 18.04.2022.
//

import Foundation

#warning("Расписать комментарии") 
///  Модель ответа для новостей.
final class NewsPostModel: RealmModel {
    let sourceId: Int
    let date: Double
    let canDoubtCategory: Bool?
    let canSetCategory: Bool?
    let isFavorite: Bool
    let postType: String
    let text: String
    let attachments: [Attachment]?
    let postSource: PostSource
    let comments: Comments
    let likes: Likes
    let reposts: Reposts
    let views: Views?
    var donut: Donut
    let shortTextRate: Double
    let postId: Int
    let type: String

    enum CodingKeys: String, CodingKey {
        case sourceId = "source_id"
        case date
        case canDoubtCategory = "can_doubt_category"
        case canSetCategory = "can_set_category"
        case isFavorite = "is_favorite"
        case postType = "post_type"
        case text
        case attachments
        case postSource = "post_source"
        case comments
        case likes
        case reposts
        case views
        case donut
        case shortTextRate = "short_text_rate"
        case postId = "post_id"
        case type
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.sourceId = try container.decode(Int.self, forKey: .sourceId)
    
        // self.date = Date(timeIntervalSince1970: TimeInterval(stamp))
        self.date = try container.decode(Double.self, forKey: .date)

        do {
            self.canDoubtCategory = try container.decode(Bool.self, forKey: .canDoubtCategory)
        } catch {
            self.canDoubtCategory = nil
        }
        do {
            self.canSetCategory = try container.decode(Bool.self, forKey: .canSetCategory)
        } catch {
            self.canSetCategory = nil
        }

        self.isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        self.postType = try container.decode(String.self, forKey: .postType)
        self.text = try container.decode(String.self, forKey: .text)

        do {
            self.attachments = try container.decode([Attachment].self, forKey: .attachments)
        } catch {
            self.attachments = nil
        }

        self.postSource = try container.decode(PostSource.self, forKey: .postSource)
        self.comments = try container.decode(Comments.self, forKey: .comments)
        self.likes = try container.decode(Likes.self, forKey: .likes)
        self.reposts = try container.decode(Reposts.self, forKey: .reposts)

        do {
            self.views = try container.decode(Views.self, forKey: .views)
        } catch {
            self.views = nil
        }

        self.donut = try container.decode(Donut.self, forKey: .donut)
        self.shortTextRate = try container.decode(Double.self, forKey: .shortTextRate)
        self.donut = try container.decode(Donut.self, forKey: .donut)
        self.postId = try container.decode(Int.self, forKey: .postId)
        self.type = try container.decode(String.self, forKey: .type)
    }
}
